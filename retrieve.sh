#!/bin/sh

set -x

[ ! $# -eq 1 ] && echo "Usage: $0 <token>" && exit 1

VAULT_TOKEN="$1"
VAULT_ADDR="http://localhost:8200"

# SECRET_PATH=/v1/secret/data/my_app_1
SECRET_PATH=/v1/cubbyhole/my_app_1

curl -X GET $VAULT_ADDR$SECRET_PATH \
-H "x-vault-token: $VAULT_TOKEN"
