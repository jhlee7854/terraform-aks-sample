resource "azurerm_user_assigned_identity" "aks_uai" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = module.const.location

  name = "${module.const.default_name_prefix}-mi"

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_role_assignment" "aks_subnet_role_assignment" {
  scope                = azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_uai.principal_id

  depends_on = [
    azurerm_user_assigned_identity.aks_uai
  ]
}

resource "azurerm_role_assignment" "aks_routetable_role_assignment" {
  scope                = azurerm_route_table.aks_subnet_route_table.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_uai.principal_id

  depends_on = [
    azurerm_user_assigned_identity.aks_uai
  ]
}

resource "azurerm_role_assignment" "aks_acr_role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.aks_uai.principal_id

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_user_assigned_identity.aks_uai
  ]
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${module.const.service_name}-${module.const.environment}-log-analytics-workspace-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = module.const.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = var.log_analytics_workspace_sku

    tags = module.const.tags
}

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.log_analytics_workspace.location
    resource_group_name   = azurerm_resource_group.rg.name
    workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
    workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }

    tags = module.const.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${module.const.default_name_prefix}-aks"
  location            = module.const.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${module.const.service_name}-${module.const.environment}-aks"

  default_node_pool {
    name                = "default"
    max_count           = var.aks_max_count
    min_count           = var.aks_min_count
    node_count          = var.aks_node_count
    vm_size             = var.aks_vm_size
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    enable_auto_scaling = true
    tags                = module.const.tags
  }

  identity {
    type = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_uai.id
  }

  kubernetes_version  = var.aks_kubernetes_version

  linux_profile {
    admin_username = "adminuser"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin     = "kubenet"
    network_policy     = "calico"
    dns_service_ip     = "10.2.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.2.0.0/16"
  }

  private_cluster_enabled = false

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
    }
  }

  tags = module.const.tags

  depends_on = [
    azurerm_role_assignment.aks_subnet_role_assignment,
    azurerm_role_assignment.aks_routetable_role_assignment,
    azurerm_role_assignment.aks_acr_role_assignment
  ]
}