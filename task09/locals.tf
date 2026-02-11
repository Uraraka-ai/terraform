locals {
  # Resource abbreviations following Azure best practices
  resource_abbreviations = {
    firewall_subnet = "snet"
    public_ip       = "pip"
    firewall        = "afw"
    route_table     = "rt"
  }
  aks_subnet_name = "aks-snet"
  vnet_name       = format("%s-vnet", lower(var.naming_prefix))
  aks_name        = format("%s-aks", lower(var.naming_prefix))
  rg_name         = format("%s-rg", lower(var.naming_prefix))
  # Common tags for all resources
  common_tags = {
    Environment = "Training"
    ManagedBy   = "Terraform"
    Project     = "Module9"
  }
}