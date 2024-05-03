#!/bin/bash
# Copyright 2024 - 2024, Bruno Thomsen and the home-router contributors
# SPDX-License-Identifier: BSD-3-Clause

set -e
set -u

export WAN_INTERFACE=""
export LAN_INTERFACE=""
export LAN_NETWORK="192.168.1.1/24"
export BRIDGE_INTERFACE="br0"

export DOMAIN_NAME=""
export DNS_SERVER="1.1.1.2"
export DHCP_LOW=""
export DHCP_HIGH=""

install_packages()
{
    dnf install -y git dhcp-server gettext-envsubst dnf-automatic patch
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

setup_dhcp_server()
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
    cp -v "conf.d/08-home-router-sshd" "/etc/ssh/sshd_config.d/"
}

install_packages
setup_auto_update
setup_wan_interface
setup_lan_interface
setup_bridge
setup_dhcp_server
setup_ssh_server
