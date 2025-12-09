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
#                      Create AKS Admin Group & Admin User                      
########################################################################

if [[ "$tenant_type" = "DEV" ]]; then
  # Create Azure AD Group
  echo "Create AKS admins group"
  adminGroupId=$(az ad group create --display-name $aksAdminGroup --mail-nickname aksadmins --query id -o tsv)

  # Create Azure AD AKS Admin User
  echo "Create AKS admin user"
  adminUserId=$(az ad user create \
                            --display-name $aksAdminUser \
                            --user-principal-name $aksAdminUser@$tenantName.onmicrosoft.com \
                            --password $aksAdminPass \
                            --query id -o tsv) 

  # Associate aksadmin User to aksadmins Group                            
  echo "Add the user to the admin group"
  az ad group member add --group $adminGroupId --member-id $adminUserId

  echo "AKS admin group ID: $adminGroupId and user ID: $adminUserId"
else
  echo If Azure Entra ID not configured, please contact Azure Enterprise Admin responsible for $tenantId
fi

########################################################################
#               Create AKS Cluster      
########################################################################
<<'END_COMMENT'
AKS allows you to quickly deploy a production ready Kubernetes cluster in Azure.
AKS offloads the cluster management operational tasks to Azure, 
where Azure handles the Kubernetes control plane and simplifies the worker nodes' setup.
END_COMMENT

# Deploy a new AKS cluster
echo "Deploy the new $aksName AKS cluster"
az aks create -n $aksName -g $rg \
             --kubernetes-version $k8sVersion \
             --network-plugin azure \
             --enable-aad \
             --enable-managed-identity \
             --aad-tenant-id $tenantId \
             --location $location \
             --appgw-name $gatewayName \
             --appgw-subnet-cidr $agwSubnetCidr \
             --attach-acr $acrName \
             --max-pods 110 \
             --node-vm-size $nodeVmSize \
             --nodepool-name "agentpool" \
             --node-count $nodeCount \
             --node-osdisk-size 128 \
             --os-sku AzureLinux \
             --load-balancer-sku standard \
             --tier free \
             --enable-addons azure-keyvault-secrets-provider,ingress-appgw \
             --output table
             
             #--workspace-resource-id $workspaceResourceId \
             # --disable-local-accounts \ # Doesn't work with DevOps: "message": "Getting static credential is not allowed because this cluster is set to disable local accounts."
             # --enable-secret-rotation # Enable secret rotation. Use with azure-keyvault-secrets-provider addon.
             # --rotation-poll-interval # Set interval of rotation poll. Use with azure-keyvault-secrets-provider addon.