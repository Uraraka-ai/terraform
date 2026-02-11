# Data source to get existing resource group
data "azurerm_resource_group" "main" {
  name = local.rg_name
}

# Data source to get existing virtual network
data "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.main.name
}

# Data source to get existing AKS subnet
data "azurerm_subnet" "aks" {
  name                 = local.aks_subnet_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

# Call our Azure Firewall module
module "afw" {
  source              = "./modules/afw"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = data.azurerm_virtual_network.main.name
  vnet_id             = data.azurerm_virtual_network.main.id
  aks_subnet_id       = data.azurerm_subnet.aks.id
  aks_loadbalancer_ip = var.aks_loadbalancer_ip
  naming_prefix       = var.naming_prefix
  aks_cluster_name    = var.aks_cluster_name
  aks_nsg_name        = var.aks_nsg_name

  tags = local.common_tags
}