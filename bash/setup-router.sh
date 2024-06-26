#!/bin/bash
# Copyright 2024 - 2024, Bruno Thomsen and the home-router contributors
# SPDX-License-Identifier: BSD-3-Clause

set -e # Exit script if any statement returns a non-true value.
set -u # Exit script if using an uninitialised variable.

PKG_VERSION="0.3.0-dev"

################################################################################
# Mandatory Configuration
################################################################################

export WAN_INTERFACE=""
export LAN_INTERFACE=""

################################################################################
# Optional Configuration
################################################################################

# LAN_NETWORK contain IP address for router LAN interface and
# local network size in CIDR Subnet Mask Notation.

export LAN_NETWORK="192.168.82.82/24"

# DOMAIN_NAME is used for FQDN lookup of devices on local network.
# ICANN has created .internal TLD for use with 192.168.x.x networks.
# NOT SUPPORTED AT THE MOMENT

export DOMAIN_NAME="tux.internal"

# DNS_SERVER_PRIMARY and DNS_SERVER_SECONDARY should be configured to
# a fast one and that is most likely not your ISPs.
#
# Cloudflare DNS is a secure, fast, privacy-first DNS resolver.
# No blocking or filtering content:
# 1.1.1.1 and 1.0.0.1
# Block Malware:
# 1.1.1.2 and 1.0.0.2
# Block Malware and Adult Content:
# 1.1.1.3 and 1.0.0.3

export DNS_SERVER_PRIMARY="1.1.1.2"
export DNS_SERVER_SECONDARY="1.0.0.2"

# DHCP_LOW and DHCP_HIGH is the IP address pool for DHCP clients.

export DHCP_LOW="192.168.82.100"
export DHCP_HIGH="192.168.82.199"

# BRIDGE_INTERFACE is used for routing packages between LAN_INTERFACE and
# WAN_INTERFACE.

export BRIDGE_INTERFACE="br0"

################################################################################
# Experimental/Deprecated Configuration
################################################################################

# EXPERIMENTAL_KEA_DHCP_SERVER changes DHCP server from ISC DHCP to ISC KEA.
# 1 = ISC KEA
# 0 = ISC DHCP

export EXPERIMENTAL_KEA_DHCP_SERVER=0

if [ -f local.cfg ]; then
    source local.cfg
fi

################################################################################
# Implementation
################################################################################

source /etc/os-release

GREEN='\033[0;32m'
BLUE='\033[94m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
GRAY='\033[2m'
NC='\033[0m' # No Color

print_header()
{
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BLUE}${FUNCNAME[1]}${NC}"
    echo -e "${GRAY}========================================${NC}"
}

start_check()
{
    echo -e "${GREEN}home-router v${PKG_VERSION}${NC}"
    print_header

    if [ "${NAME}" != "Fedora Linux" ]; then
        echo -e "${YELLOW}Warning: Untested distribution (${NAME})${NC}"
    fi

    echo "Distribution: ${PRETTY_NAME}"
    echo "WAN interface: ${WAN_INTERFACE}"
    echo "LAN interface: ${LAN_INTERFACE}"
    echo "Bridge interface: ${BRIDGE_INTERFACE}"
    echo "LAN network: ${LAN_NETWORK}"
    echo "DHCP client pool: ${DHCP_LOW} - ${DHCP_HIGH}"
    echo "DHCP client dns: ${DNS_SERVER_PRIMARY}, ${DNS_SERVER_SECONDARY}"

    if [ -z "${WAN_INTERFACE}" ] || [ -z "${LAN_INTERFACE}" ]; then
        echo -e "${RED}Error: Missing interface information${NC}"
        exit 1
    fi
}

install_packages()
{
    print_header

    DNF_INSTALL_PKG=( dnf-automatic patch gettext-envsubst ipcalc )
    if [ "${EXPERIMENTAL_KEA_DHCP_SERVER}" -eq 1 ]; then
        DNF_INSTALL_PKG+=( kea )
    else
        DNF_INSTALL_PKG+=( dhcp-server )
    fi
    dnf install --setopt=install_weak_deps=False --setopt=tsflags=nocontexts,nodocs --best -y "${DNF_INSTALL_PKG[@]}"
}

setup_auto_update()
{
    print_header

    dnf_override_path="/etc/systemd/system/dnf-automatic-install.timer.d"
    mkdir -p "${dnf_override_path}"
    cp -v "conf.d/dnf-override.conf" "${dnf_override_path}"
    patch --forward -r - "/etc/dnf/automatic.conf" "patches/dnf-reboot-when-needed.patch" || true
    systemctl daemon-reload
    systemctl enable dnf-automatic-install.timer
    systemctl start dnf-automatic-install.timer
}

setup_wan_firewall()
{
    print_header

    firewall-cmd --set-default-zone=external
    firewall-cmd --permanent --zone=external --add-service=dhcpv6-client
    firewall-cmd --permanent --zone=external --add-service=ssh
    firewall-cmd --permanent --zone=external --add-interface="${WAN_INTERFACE}"
    firewall-cmd --permanent --zone=external --add-interface="${BRIDGE_INTERFACE}" || true
}

setup_lan_firewall()
{
    print_header

    firewall-cmd --permanent --zone=internal --remove-service=dhcpv6-client
    firewall-cmd --permanent --zone=internal --remove-service=samba-client
    firewall-cmd --permanent --zone=internal --add-service=dhcp
    firewall-cmd --permanent --zone=internal --add-service=dns
    firewall-cmd --permanent --zone=internal --add-service=ssh
    firewall-cmd --permanent --zone=internal --add-interface="${LAN_INTERFACE}"
}

setup_bridge()
{
    print_header

    if PAGER="" nmcli connection show "${BRIDGE_INTERFACE}" > /dev/null 2>&1; then
        nmcli connection delete "${BRIDGE_INTERFACE}"
    fi
    if PAGER="" nmcli connection show "bridge-slave-${LAN_INTERFACE}" > /dev/null 2>&1; then
        nmcli connection delete "bridge-slave-${LAN_INTERFACE}"
    fi
    nmcli connection add \
        ifname "${BRIDGE_INTERFACE}" \
        type bridge \
        con-name "${BRIDGE_INTERFACE}" \
        bridge.stp no \
        ipv4.addresses "${LAN_NETWORK}" \
        ipv4.method manual
    nmcli connection add \
        ifname "${LAN_INTERFACE}" \
        type bridge-slave \
        master "${BRIDGE_INTERFACE}"

    cp -v "conf.d/10-kernel-router.conf" "/etc/modules-load.d/"
}

setup_isc_dhcp_server()
{
    print_header

    export "$(ipcalc --address ${LAN_NETWORK})"
    export "$(ipcalc --network ${LAN_NETWORK})"
    export "$(ipcalc --netmask ${LAN_NETWORK})"
    export "$(ipcalc --minaddr ${LAN_NETWORK})"
    export "$(ipcalc --broadcast ${LAN_NETWORK})"
    envsubst < "template/dhcpd.conf.template" > "/etc/dhcp/dhcpd.conf"
    systemctl enable dhcpd
    systemctl restart dhcpd
}

remove_isc_dhcp_server()
{
    print_header

    dnf remove -y dhcp-server
}

setup_kea_dhcp_server()
{
    print_header

    export "$(ipcalc --address ${LAN_NETWORK})"
    export "$(ipcalc --network ${LAN_NETWORK})"
    export "$(ipcalc --prefix ${LAN_NETWORK})"
    envsubst < "template/kea.conf.template" > "/etc/kea/kea-dhcp4.conf"
    systemctl enable kea-dhcp4
    systemctl restart kea-dhcp4
}

remove_kea_dhcp_server()
{
    print_header

    dnf remove -y kea
}

setup_ssh_server()
{
    print_header

    cp -v "conf.d/08-home-router-sshd.conf" "/etc/ssh/sshd_config.d/"
}

firewall_status()
{
    print_header

    firewall-cmd --reload
    firewall-cmd --info-zone=external
    firewall-cmd --info-zone=internal
}

start_check
install_packages
setup_auto_update
setup_bridge
setup_wan_firewall
setup_lan_firewall
if [ "${EXPERIMENTAL_KEA_DHCP_SERVER}" -eq 1 ]; then
    echo -e "${YELLOW}Warning: Experimental KEA DHCP server enabled${NC}"
    remove_isc_dhcp_server
    setup_kea_dhcp_server
else
    remove_kea_dhcp_server
    setup_isc_dhcp_server
fi
setup_ssh_server
firewall_status
