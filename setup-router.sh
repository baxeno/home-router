#!/bin/bash

set -e
set -u

WAN_INTERFACE=""
LAN_INTERFACE=""
LAN_NETWORK="192.168.1.1/24"
BRIDGE_INTERFACE="br0"

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
