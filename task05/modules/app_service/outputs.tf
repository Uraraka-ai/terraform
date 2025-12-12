output "id" {
  value       = azurerm_windows_web_app.this.id
  description = "The ID of the Windows App Service."
}

output "name" {
  value       = azurerm_windows_web_app.this.name
  description = "The name of the Windows App Service."
}

output "default_hostname" {
  value       = azurerm_windows_web_app.this.default_hostname
  description = "The default hostname of the Windows App Service."
}