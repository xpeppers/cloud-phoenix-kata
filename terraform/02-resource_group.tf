# Create resource group
resource "azurerm_resource_group" "demo-terraform-resource-group" {
  name     = var.terraform_resource_group
  location = var.location

  tags = {
    environment = var.terraform_env
    owner       = var.terraform_env_owner
  }
}

