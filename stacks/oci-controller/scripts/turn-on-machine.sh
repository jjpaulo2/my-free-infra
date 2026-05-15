#!/usr/bin/env bash

VM_ALIAS="$1";

if [ -z "$VM_ALIAS" ]; then
    echo "USAGE: $0 <VM_ALIAS>";
    exit 1;
fi;

VM_ID_VAR_NAME="VM_$VM_ALIAS";
VM_ID="${!VM_ID_VAR_NAME}";

if [ -z "$VM_ID" ]; then
    echo "ERROR: Please set the environment variable '$VM_ID_VAR_NAME'.";
    exit 1;
fi;

oci compute instance action \
    --instance-id "$VM_ID" \
    --action START \
    --auth instance_principal;
