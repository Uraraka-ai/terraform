resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Windows"
  reserved            = false

  sku {
    tier     = "Standard"
    size     = var.sku
    capacity = var.worker_count
  }

  tags = var.tags
}