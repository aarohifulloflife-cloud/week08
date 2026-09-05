location            = "eastasia"
resource_group_name = "koalatech-week08-rg"

# Replace with a unique name for your Azure Container Registry 
acr_name             = "sit722acr225138095"

# Replace with a unique name for your Azure Storage Account
storage_account_name = "sit722st225138095"

# Replace with a unique name for your Azure Kubernetes Service cluster
aks_cluster_name = "sit722-aks-225138095"
aks_dns_prefix   = "koalatech"

aks_node_count   = 2
aks_node_vm_size = "Standard_D2s_v3"

environment = "development"

tags = {
    Project    = "KoalaTech Course Platform"
    ManagedBy  = "Terraform"
    Practical  = "Week08"
    Environment = "Development"
}