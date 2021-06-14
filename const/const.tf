variable "organization" {
  type = string
  default = "org"
}
variable "service_name" {
  type = string
  default = "demo"
}
variable "environment" {
  type = string
}
variable "owner" {
  type = string
  default = "jonghak"
}
variable "operator" {
  type = string
  default = "jonghak"
}
variable "location" {
  type = string
  default = "koreacentral"
}
variable "location_alias" {
  type = string
  default = "koce"
}

output "organization" { value = var.organization }
output "service_name" { value = var.service_name }
output "environment" { value = var.environment }
output "owner" { value = var.owner }
output "operator" { value = var.operator }
output "location" { value = var.location }
output "location_alias" { value = var.location_alias }
output "default_name_prefix" {
  value = "${var.organization}-${var.service_name}-${var.environment}-${var.location_alias}"
}

output "tags" {
    value = {
        "Organization" = var.organization
        "Service Name" = var.service_name
        "Environment" = var.environment
        "Operator" = var.operator
        "Owner" = var.owner
        "Created By" = "terraform"
    }
}