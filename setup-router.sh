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

#firewall-cmd --list-all-zones
firewall-cmd --set-default-zone=external
firewall-cmd --permanent --zone=external --add-service=dhcpv6-client
firewall-cmd --reload

firewall-cmd --permanent --zone=internal --add-interface="${LAN_INTERFACE}"
firewall-cmd --permanent --zone=internal --remove-service=dhcpv6-client
firewall-cmd --permanent --zone=internal --remove-service=samba-client
firewall-cmd --permanent --zone=internal --add-service=dhcp
firewall-cmd --permanent --zone=internal --add-service=dns
firewall-cmd --reload

nmcli connection add ifname "${BRIDGE_INTERFACE}" type bridge con-name "${BRIDGE_INTERFACE}" bridge.stp no ipv4.addresses "${LAN_NETWORK}" ipv4.method manual
nmcli connection add type bridge-slave ifname "${LAN_INTERFACE}" master "${BRIDGE_INTERFACE}"
firewall-cmd --permanent --zone=internal --add-interface="${BRIDGE_INTERFACE}"
firewall-cmd --reload

# Setup DHCP server
export "$(ipcalc --address ${LAN_NETWORK})"
export "$(ipcalc --network ${LAN_NETWORK})"
export "$(ipcalc --netmask ${LAN_NETWORK})"
export "$(ipcalc --minaddr ${LAN_NETWORK})"
export "$(ipcalc --broadcast ${LAN_NETWORK})"
envsubst < "template/dhcpd.conf.template" > "/etc/dhcp/dhcpd.conf"
systemctl enable dhcpd
systemctl restart dhcpd
