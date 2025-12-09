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
#            Create Network Resources - vnet, subnet & puplic IP                
########################################################################

# Create the virtual network & subnet dedicated to application gateway
az network vnet create \
 --name $vNetName \
 --resource-group $rg \
 --location $location \
 --address-prefix $vNetAddrPrefix \
 --subnet-name $agwsubnetName \
 --subnet-prefix $agwSubnetCidr \
 --output table

# Create subnet dedicated to AKS cluster
az network vnet subnet create \
 --name $aksSubnetName \
 --resource-group $rg \
 --vnet-name $vNetName \
 --address-prefix $AksSubnetCidr \
 --output table

# Create public ip address
az network public-ip create \
    --resource-group $rg \
    --name $agwPublicIPName 

########################################################################
#               Create Application Gateway      
########################################################################

az network application-gateway create \
 --name $gatewayName \
 --location $location \
 --resource-group $rg \
 --vnet-name $vNetName \
 --subnet $agwsubnetName \
 --capacity 2 \
 --sku Standard_v2 \
 --http-settings-cookie-based-affinity Disabled \
 --frontend-port 80 \
 --http-settings-port 80 \
 --http-settings-protocol Http \
 --public-ip-address $agwPublicIPName \
 --priority 100 \
 --output table



