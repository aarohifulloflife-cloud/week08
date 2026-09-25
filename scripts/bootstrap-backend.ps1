# Bootstrap the Terraform remote state backend. Run ONCE, locally.
# Separate resource group so destroying the app infrastructure does
# not destroy the record of what was built.

$ErrorActionPreference = "Stop"

$RG        = "sit722-tfstate-rg"
$ACCOUNT   = "sit722tfstate225138095"
$CONTAINER = "tfstate"
$LOCATION  = "eastasia"

Write-Host "Creating resource group $RG"
az group create --name $RG --location $LOCATION

Write-Host "Creating storage account $ACCOUNT"
az storage account create `
  --name $ACCOUNT `
  --resource-group $RG `
  --location $LOCATION `
  --sku Standard_LRS `
  --encryption-services blob `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false

Write-Host "Creating container $CONTAINER"
az storage container create `
  --name $CONTAINER `
  --account-name $ACCOUNT `
  --auth-mode login

Write-Host ""
Write-Host "Backend ready. Now run:"
Write-Host "  cd terraform"
Write-Host "  terraform init -migrate-state"
Write-Host ""
Write-Host "Then grant the service principal access:"
Write-Host "  az role assignment create --assignee <SP-CLIENT-ID> --role 'Storage Blob Data Contributor' --scope /subscriptions/<SUB>/resourceGroups/$RG"
