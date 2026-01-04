#!/bin/bash
# SPDX-License-Identifier: Apache-2.0

set -e # Exit script if any statement returns a non-true value.
set -u # Exit script if using an uninitialised variable.

INVENTORY_YAML_FILES=(
    localhost.yml
    test-alma10.yml
)

# Additional information is printed with 2 x verbose
for inventory_file in "${INVENTORY_YAML_FILES[@]}"; do
    ansible-playbook \
        --syntax-check \
        --verbose \
        --verbose \
        --inventory "inventory/${inventory_file}" \
        home-router.yml
done

printf "\nValidated successful in %s seconds\n" "$SECONDS"

