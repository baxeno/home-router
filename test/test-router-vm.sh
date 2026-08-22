#!/bin/bash
# SPDX-License-Identifier: Apache-2.0

set -e # Exit script if any statement returns a non-true value.
set -u # Exit script if using an uninitialised variable.

source /etc/os-release

GREEN='\033[0;32m'
BLUE='\033[94m'
#YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
GRAY='\033[2m'
NC='\033[0m' # No Color

KEA_SERVICE="kea-dhcp4.service"
KEA_LEASES="/var/lib/kea/kea-leases4.csv"
CHRONYD_SERVICE="chronyd.service"

print_header()
{
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BLUE}${1}${NC}"
    echo -e "${GRAY}----------------------------------------${NC}"
}

print_service_status()
{
    service="${1}"
    print_header "${service} status"
    systemctl status --no-pager -l "${service}"
    if systemctl is-active "${service}" > /dev/null; then
        echo -e "${service} [${GREEN}OK${NC}]"
    else
        echo -e "${service} [${RED}FAILED${NC}]"
    fi
}

print_dhcp_server_leases()
{
    print_header "${KEA_SERVICE} leases"
    cat "${KEA_LEASES}" | column -s, -t
}



print_firewall_zone()
{
    local zone="${1}"
    print_header "Firewall zone=${zone}"
    firewall-cmd --zone="${zone}" --list-all

}

# Tests
print_service_status "${KEA_SERVICE}"
print_service_status "${CHRONYD_SERVICE}"
print_dhcp_server_leases
print_firewall_zone "external"
print_firewall_zone "internal"

echo -e "${GREEN}Completed check${NC}"

