#!/bin/sh 
#
#
# This script assigns a role to a user in the Key Vault
#
# Usage:
# $ ./addKeyvaultRoleToUser.sh <object-id-of-the-user> <role: Key Vault Secrets Officer | Key Vault Secrets User ... >
#
# Example: 
#
# Read and write access:
# ./addKeyvaultRoleToUser.sh 00000000-0000-0000-0000-000000000000 "Key Vault Secrets Officer"
#
# Read only access
# ./addKeyvaultRoleToUser.sh 00000000-0000-0000-0000-000000000000 "Key Vault Secrets User"
#
# Pre-requisites:
#  1. Azure CLI installed in the machine running the script and user logged in.
#  2. User should have permissions to assign roles to the user in the Key Vault
#  3. The .env file should have the keyVaultName variable set
#
#

if [[ -f .env ]]; then
  set -a
  source .env set
  set +a
else
  echo "The .env file does not exist."
  exit 1
fi


usage() {
  echo "usage: $0 <object-id-of-the-user> <role: Key Vault Secrets Officer | Key Vault Secrets User >"
  exit 1
}

# check if $1 is empty
if [ -z "$1" ]; then
  usage
fi

# check if $2 is empty
if [ -z "$2" ]; then
  usage
fi

# check if $keyVaultName is empty
if [ -z "$keyVaultName" ]; then
    echo "keyVaultName is empty. Add it to environment"
    exit 1
fi

set -e
echo keyVaultName: $keyVaultName
echo assignee: $1
echo permission $2

echo "Getting keyvault scope..."
KEYVAULT_SCOPE=$(az keyvault show --name $keyVaultName --query id -o tsv)
echo keyvault scope: $KEYVAULT_SCOPE

echo "Assigning role to the user..."
az role assignment create --role $2 --assignee $1 --scope $KEYVAULT_SCOPE
