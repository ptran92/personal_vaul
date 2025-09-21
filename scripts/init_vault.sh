#!/bin/sh

# Set Vault address
export VAULT_ADDR=http://localhost:8200

# Add jq if not available
apk add --no-cache jq

# Set up secrets KV in vault if not available
function setup_kv_secret_and_run() {
    # Start Vault server in the background
    vault server -config=/vault/config/vault.hcl &

    # Wait for Vault to be ready
    sleep 5

    # Check if Vault is initialized
    INIT_FILE="/vault/file/vault-init.json"
    if ! vault status | grep -q "Initialized.*true"; then
        echo "Initializing Vault..."
        # Initialize with 3 keys, 2 required (adjust as needed)
        INIT_OUTPUT=$(vault operator init -key-shares=3 -key-threshold=2 -format=json)
        echo "$INIT_OUTPUT" > $INIT_FILE
        echo "Vault initialized. Unseal keys and root token saved to $INIT_FILE"
    else
        echo "Vault already initialized."
    fi

    UNSEAL_KEYS=$(grep -o '"unseal_keys_b64": \[.*\]' $INIT_FILE | grep -o '"[^"]\+"' | head -n 2)
    # Unseal Vault using keys from init file
    UNSEAL_KEYS=$(jq -r '.unseal_keys_b64[]' $INIT_FILE | head -n 2)
    for KEY in $UNSEAL_KEYS; do
        vault operator unseal $KEY
    done

    # Log in with root token
    ROOT_TOKEN=$(jq -r '.root_token' $INIT_FILE)
    vault login $ROOT_TOKEN

    # Enable KV-v2 secrets engine if not already enabled
    vault secrets list | grep -q "secret/" || vault secrets enable -path=secret kv-v2

    echo "KV secrets engine enabled at secret/"

    # Keep container running
    wait
}  

function main() {
    setup_kv_secret_and_run
}

main






 