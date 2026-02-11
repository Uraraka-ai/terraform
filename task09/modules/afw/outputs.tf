output "firewall_public_ip" {
  description = "Public IP address of the Azure Firewall"
  value       = azurerm_public_ip.firewall.ip_address
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_name" {
  description = "Name of the Azure Firewall"
  value       = azurerm_firewall.main.name
}

output "route_table_id" {
  description = "ID of the Route Table"
  value       = azurerm_route_table.firewall.id
}

output "aks_nsg_name" {
  description = "Name of the AKS Network Security Group"
  value       = length(data.azurerm_resources.aks_nsg.resources) > 0 ? element(data.azurerm_resources.aks_nsg.resources, 0).name : ""
}

output "aks_nsg_id" {
  description = "ID of the AKS Network Security Group"
  value       = length(data.azurerm_resources.aks_nsg.resources) > 0 ? element(data.azurerm_resources.aks_nsg.resources, 0).id : ""
}