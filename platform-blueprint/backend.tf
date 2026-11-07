# Remote Backend with Azure Storage Blob State Locking via Lease
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-prod-eastus"
    storage_account_name = "sttfstateprodeastus01"
    container_name       = "platform-tfstate"
    key                  = "enterprise.platform.terraform.tfstate"
    use_azuread_auth     = true
  }
}
