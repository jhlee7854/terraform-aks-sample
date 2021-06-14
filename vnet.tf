resource "azurerm_virtual_network" "vnet" {
  name                = "${module.const.default_name_prefix}-vnet"
  location            = module.const.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space

  tags = module.const.tags

  depends_on = [
    azurerm_resource_group.rg
  ]
}