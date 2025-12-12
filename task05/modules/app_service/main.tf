resource "azurerm_windows_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.app_service_plan_id
  tags                = var.tags

  site_config {
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name        = ip_restriction.value.name
        ip_address  = ip_restriction.value.ip_address
        service_tag = ip_restriction.value.service_tag
        action      = ip_restriction.value.action
        priority    = ip_restriction.value.priority
      }
    }
    ip_restriction_default_action = "Deny"
  }
}