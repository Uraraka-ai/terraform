output "id" {
  value       = azurerm_app_service_plan.this.id
  description = "The ID of the App Service Plan."
}

output "name" {
  value       = azurerm_app_service_plan.this.name
  description = "The name of the App Service Plan."
}