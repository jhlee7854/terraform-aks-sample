resource "azurerm_container_registry" "acr" {
  name                     = "${module.const.organization}${module.const.service_name}${module.const.location_alias}acr"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = module.const.location
  sku                      = "Basic"
  admin_enabled            = false
  
  tags = module.const.tags

  depends_on = [
    azurerm_resource_group.rg
  ]
}