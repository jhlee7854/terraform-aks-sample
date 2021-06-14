resource "azurerm_subnet" "aks_subnet" {
  name                 = "${module.const.default_name_prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_address_prefixes

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_network_security_group" "aks_subnet_nsg" {
    name                = "${module.const.default_name_prefix}-aks-subnet-nsg"
    location            = module.const.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = module.const.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_subnet_nsg.id
}

resource "azurerm_route_table" "aks_subnet_route_table" {
  name                          = "${module.const.default_name_prefix}-aks-subnet-routetable"
  location                      = module.const.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  tags = module.const.tags
}

resource "azurerm_subnet_route_table_association" "aks_subnet_routetable_association" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks_subnet_route_table.id
}