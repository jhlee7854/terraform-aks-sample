terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-state-demo-rg"
    storage_account_name  = "tstate1307322"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}

# Configure the Azure provider
provider "azurerm" { 
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}

variable environment { type = string }

variable address_space { type = list }
variable aks_subnet_address_prefixes { type = list }

variable ssh_public_key { type = string }
variable aks_kubernetes_version { type = string }
variable aks_node_count { type = number }
variable aks_vm_size { type = string }
variable log_analytics_workspace_sku { type = string } # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 

module "const" {
    source = "./const"
    environment = var.environment
}