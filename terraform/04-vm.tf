# Create log analytics profile
resource "azurerm_log_analytics_workspace" "demo" {
  name                = var.analytics_name
  location            = var.location
  resource_group_name = azurerm_resource_group.demo-terraform-resource-group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


# Create K8s cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.demo-terraform-resource-group.name
  dns_prefix          = var.dns_prefix

/*  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
*/
  agent_pool_profile {
    name            = "default"
    count           = var.agent_count
    vm_size         = "Standard_B2s"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.demo.id
    }
  }

  tags = {
    Environment = "K8s Xpeppers test"
  }
}

