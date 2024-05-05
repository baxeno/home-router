#!/bin/bash
# Copyright 2024 - 2024, Bruno Thomsen and the home-router contributors
# SPDX-License-Identifier: BSD-3-Clause

set -e # Exit script if any statement returns a non-true value.
set -u # Exit script if using an uninitialised variable.

VERSION="0.2.0-dev"

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
# NOT SUPPORTED AT THE MOMENT

export DOMAIN_NAME="tux.local"

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
export DNS_SERVER_SECONDAY="1.0.0.2"

# DHCP_LOW and DHCP_HIGH is the IP address pool for DHCP clients.

export DHCP_LOW="192.168.82.100"
export DHCP_HIGH="192.168.82.199"

# BRIDGE_INTERFACE is used for routing packages between LAN_INTERFACE and
# WAN_INTERFACE.

export BRIDGE_INTERFACE="br0"


################################################################################
# Implementation
################################################################################

start_check()
{
    echo "home-router v${VERSION}"
}

install_packages()
{
    DNF_INSTALL_PKG=( dnf-automatic patch gettext-envsubst )
    DNF_INSTALL_PKG+=( dhcp-server )
    dnf --setopt=install_weak_deps=False --setopt=tsflags=nocontexts,nodocs --best -y "${DNF_INSTALL_PKG[@]}"
}

setup_auto_update()
{
    dnf_override_path="/etc/systemd/system/dnf-automatic-install.timer.d"
    mkdir -p "${dnf_override_path}"
    cp -v "conf.d/dnf-override.conf" "${dnf_override_path}"
    patch --forward -r - "/etc/dnf/automatic.conf" "patches/dnf-reboot-when-needed.patch" || true
    systemctl daemon-reload
    systemctl enable dnf-automatic-install.timer
    systemctl start dnf-automatic-install.timer
}

setup_wan_interface()
{
    firewall-cmd --set-default-zone=external
    firewall-cmd --permanent --zone=external --add-service=dhcpv6-client
    #firewall-cmd --permanent --zone=external --remove-service=ssh
    firewall-cmd --reload
    firewall-cmd --info-zone=external
}

setup_lan_interface()
{
    firewall-cmd --permanent --zone=internal --add-interface="${LAN_INTERFACE}"
    firewall-cmd --permanent --zone=internal --remove-service=dhcpv6-client
    firewall-cmd --permanent --zone=internal --remove-service=samba-client
    firewall-cmd --permanent --zone=internal --add-service=dhcp
    firewall-cmd --permanent --zone=internal --add-service=dns
    firewall-cmd --reload
    firewall-cmd --info-zone=internal
}

setup_bridge()
{
    if PAGER="" nmcli connection show "${BRIDGE_INTERFACE}" 2>&1 > /dev/null; then
        nmcli connection delete "${BRIDGE_INTERFACE}"
    fi
    nmcli connection add ifname "${BRIDGE_INTERFACE}" type bridge con-name "${BRIDGE_INTERFACE}" bridge.stp no ipv4.addresses "${LAN_NETWORK}" ipv4.method manual
    nmcli connection add type bridge-slave ifname "${LAN_INTERFACE}" master "${BRIDGE_INTERFACE}"
    firewall-cmd --permanent --zone=internal --add-interface="${BRIDGE_INTERFACE}"
    firewall-cmd --reload
    firewall-cmd --info-zone=internal
}

setup_isc_dhcp_server()
{
    export "$(ipcalc --address ${LAN_NETWORK})"
    export "$(ipcalc --network ${LAN_NETWORK})"
    export "$(ipcalc --netmask ${LAN_NETWORK})"
    export "$(ipcalc --minaddr ${LAN_NETWORK})"
    export "$(ipcalc --broadcast ${LAN_NETWORK})"
    envsubst < "template/dhcpd.conf.template" > "/etc/dhcp/dhcpd.conf"
    systemctl enable dhcpd
    systemctl restart dhcpd
}

setup_ssh_server()
{
    cp -v "conf.d/08-home-router-sshd.conf" "/etc/ssh/sshd_config.d/"
}

start_check
install_packages
setup_auto_update
setup_wan_interface
setup_lan_interface
setup_bridge
setup_isc_dhcp_server
setup_ssh_server
