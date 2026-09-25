# Remote state backend. Required for Terraform-in-CI.
# A GitHub Actions runner is destroyed after every job, so local state
# would be lost between runs. Azure Storage gives every run the same
# view of what exists, and the blob lease provides locking.
# The storage account must exist BEFORE terraform init. Run
# scripts/bootstrap-backend.ps1 once to create it.

terraform {
  backend "azurerm" {
    resource_group_name  = "sit722-tfstate-rg"
    storage_account_name = "sit722tfstate225138095"
    container_name       = "tfstate"
    key                  = "week08.terraform.tfstate"
  }
}
