resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"                # or "Linux" if you need Linux
  sku_name            = var.sku                  # e.g., "S1"
  worker_count        = var.worker_count
  tags                = var.tags
}