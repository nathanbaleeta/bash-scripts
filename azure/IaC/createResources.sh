#!/usr/bin/env bash
set -e


########################################################################
#      Configure the environment specific variables from the .env file
########################################################################
if [[ -f .env ]]; then
  set -a
  source .env set
  set +a
else
  echo "The .env file does not exist."
  exit 1
fi

########################################################################
#             Configure the right subscription
########################################################################

# Tip - best to set it manually using az cli

az account set --subscription $subscription
echo "Resource group, location, subscriptionId: $rg, $location, $subscription"

########################################################################
#             Prerequisites - Register Resource Providers
########################################################################

# Check that Microsoft.OperationsManagement and Microsoft.OperationalInsights providers registered on your subscription
# We need this for Container Insights

# Tip - best to register (if unregistered) manually using azure portal - 
# https://learn.microsoft.com/en-us/answers/questions/1190234/missing-permission-microsoft-operationsmanagement

opsMan=$(az provider show -n Microsoft.OperationsManagement | jq -r .registrationState)
opsInsight=$(az provider show -n Microsoft.OperationalInsights | jq -r .registrationState)
opsStorage=$(az provider show -n Microsoft.Storage | jq -r .registrationState)

echo "Microsoft.OperationsManagement, Microsoft.OperationalInsights & Microsoft.Storage state: $opsMan, $opsInsight & $opsStorage"

if [[ "$opsMan" != "Registered" ]]; then
    echo "Register Microsoft.OperationsManagement"
    #az provider register --namespace Microsoft.OperationsManagement
fi

if [[ "$opsInsight" != "Registered" ]]; then
    echo "Register Microsoft.OperationalInsights"
    #az provider register --namespace Microsoft.OperationalInsights
fi

if [[ "$opsStorage" != "Registered" ]]; then
    echo "Register Microsoft.Storage"
    #az provider register --namespace Microsoft.Storage
fi


########################################################################
#                      Create Resource Group                        
# https://learn.microsoft.com/en-us/cli/azure/use-azure-cli-successfully-bash#using-if-then-to-create-or-delete-a-resource-group   
########################################################################
echo "Create $rg resource group for the cluster resources"

if [ $(az group exists --name $rg) = false ]; then 
   az group create --name $rg --location "$location" --output table
else
   echo The $rg resource group already exists
fi


########################################################################
#                      Create Azure Container Registry                
########################################################################

acrNameAvailable=$(az acr check-name -n $acrName --query nameAvailable)
if [[ "$acrNameAvailable" = true ]]; then
  az acr create -n $acrName -g $rg --sku basic --output table
else
  echo The $acrName ACR already exists in $rg resource group
fi


########################################################################
#                      Create Key Vault                                
########################################################################
echo "Create the $keyVaultName Key Vault"

keyVaultExists=$(az keyvault list --resource-group $rg --resource-type vault --query "contains([].name, '$keyVaultName')")
if [[ "$keyVaultExists" = false ]]; then
   echo "Create the $keyVaultName Key Vault"
   az keyvault create \
        --location $location \
        --name $keyVaultName \
        --resource-group $rg \
        --output table
else
  echo The $keyVaultName key vault already exists in $rg resource group
fi

########################################################################
#                      Create Storage Account                          
########################################################################

echo "Create the $storageAccountName Storage Account"

storageAccountExists=$(az storage account list --resource-group $rg --query "contains([].name, '$storageAccountName')")
if [[ "$storageAccountExists" = false ]]; then
   echo "Create the $storageAccountName Storage Account"
   az storage account create \
        --name $storageAccountName \
        --resource-group $rg \
        --location $location \
        --sku Standard_LRS \
        --output table
else
  echo The $storageAccountName storage account already exists in $rg resource group
fi







