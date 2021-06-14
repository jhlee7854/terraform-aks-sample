resource "azurerm_resource_group" "rg" {
    name = "${module.const.default_name_prefix}-rg"
    location = module.const.location
    tags = module.const.tags
}