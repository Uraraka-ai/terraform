output "fqdn" {
  value       = azurerm_traffic_manager_profile.this.fqdn
  description = "The FQDN of the Traffic Manager profile."
}