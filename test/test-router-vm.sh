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

print_header()
{
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BLUE}${1}${NC}"
    echo -e "${GRAY}----------------------------------------${NC}"
}

print_header "${KEA_SERVICE} status"
if systemctl is-active "${KEA_SERVICE}" > /dev/null; then
    echo -e "${KEA_SERVICE} [${GREEN}OK${NC}]"
else
    echo -e "${KEA_SERVICE} [${RED}FAILED${NC}]"
fi
systemctl status --no-pager -l "${KEA_SERVICE}"

print_header "${KEA_SERVICE} leases"
cat "${KEA_LEASES}" | column -s, -t

echo -e "${GREEN}Completed check${NC}"

