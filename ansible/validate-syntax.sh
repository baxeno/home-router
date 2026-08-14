#!/bin/bash
# SPDX-License-Identifier: Apache-2.0

set -e # Exit script if any statement returns a non-true value.
set -u # Exit script if using an uninitialised variable.

PLAYBOOK_YAML_FILE="home-router.yml"
mapfile -d $'\0' INVENTORY_YAML_FILES < <(find inventory/ -type f -name "*.yml" -print0)

# Additional information is printed with 2 x verbose
for inventory_file in "${INVENTORY_YAML_FILES[@]}"; do
    echo "Validating playbook: ${PLAYBOOK_YAML_FILE} on inventory: ${inventory_file}"
    ansible-playbook \
        --syntax-check \
        --verbose \
        --verbose \
        --inventory "${inventory_file}" \
        "${PLAYBOOK_YAML_FILE}"
    echo "----------------------------------------"
done

printf "\nValidated successful in %s seconds\n" "$SECONDS"
