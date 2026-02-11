# ============================================
# Data Sources
# ============================================
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_resources" "aks_nsg" {
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
  type                = join("/", ["Microsoft.Network", "networkSecurityGroups"])
}

# ============================================
# Firewall Subnet
# ============================================
resource "azurerm_subnet" "firewall" {
  name                 = local.firewall_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.firewall_subnet_prefix]
}

# ============================================
# Public IP for Azure Firewall
# ============================================
resource "azurerm_public_ip" "firewall" {
  name                = local.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.combined_tags

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================
# Azure Firewall
# ============================================
resource "azurerm_firewall" "main" {
  name                = local.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = local.firewall_sku_name
  sku_tier            = local.firewall_sku_tier
  tags                = local.combined_tags

  ip_configuration {
    name                 = join("-", ["firewall", "ipconfig"])
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# ============================================
# Route Table
# ============================================
resource "azurerm_route_table" "firewall" {
  name                = local.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.combined_tags

  # Default route (using join)
  route {
    name                   = local.route_name_firewall
    address_prefix         = join("/", ["0.0.0.0", "0"])
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }

  # Firewall Public IP route (using join)
  route {
    name           = local.route_name_internet
    address_prefix = join("/", [azurerm_public_ip.firewall.ip_address, "32"])
    next_hop_type  = "Internet"
  }
}

# ============================================
# Route Table Association
# ============================================
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = var.aks_subnet_id
  route_table_id = azurerm_route_table.firewall.id
}

# ============================================
# NAT Rule Collection
# ============================================
resource "azurerm_firewall_nat_rule_collection" "dnat" {
  name                = local.nat_rule_collection_name
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = local.nat_rule_priority
  action              = "Dnat"

  rule {
    name = join("-", ["allow", "http", "to", "aks", "lb"])

    source_addresses = ["*"]

    destination_ports = ["80"]

    destination_addresses = [
      azurerm_public_ip.firewall.ip_address
    ]

    translated_address = var.aks_loadbalancer_ip
    translated_port    = "80"

    protocols = local.tcp_protocols
  }
}

# ============================================
# Network Rule Collection (with for loop)
# ============================================
resource "azurerm_firewall_network_rule_collection" "aks" {
  name                = local.network_rule_collection_name
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = local.network_rule_priority
  action              = "Allow"

  dynamic "rule" {
    for_each = local.network_rules_map
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_ports     = rule.value.destination_ports
      destination_addresses = length(rule.value.destination_addresses) > 0 ? rule.value.destination_addresses : null
      destination_fqdns     = length(rule.value.destination_fqdns) > 0 ? rule.value.destination_fqdns : null
      protocols             = rule.value.protocols
    }
  }
}

# ============================================
# Application Rule Collection (with for loop)
# ============================================
resource "azurerm_firewall_application_rule_collection" "aks" {
  name                = local.application_rule_collection_name
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = local.application_rule_priority
  action              = "Allow"

  # FQDN Tag rule (using join)
  rule {
    name             = join("-", ["allow", "aks", "fqdn", "tag"])
    source_addresses = ["*"]
    fqdn_tags        = ["AzureKubernetesService"]
  }

  # Dynamic application rules
  dynamic "rule" {
    for_each = local.application_rules_map
    content {
      name             = rule.value.name
      source_addresses = rule.value.source_addresses
      target_fqdns     = length(rule.value.target_fqdns) > 0 ? rule.value.target_fqdns : null

      dynamic "protocol" {
        for_each = rule.value.protocols
        content {
          port = tostring(protocol.value.port)
          type = protocol.value.type
        }
      }
    }
  }
}

# ============================================
# NSG Rule
# ============================================
resource "azurerm_network_security_rule" "allow_firewall_to_lb" {
  name                        = local.nsg_rule_name
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = element(local.all_web_ports, 0)
  source_address_prefix       = azurerm_public_ip.firewall.ip_address
  destination_address_prefix  = var.aks_loadbalancer_ip
  resource_group_name         = data.azurerm_kubernetes_cluster.aks.node_resource_group
  network_security_group_name = element(data.azurerm_resources.aks_nsg.resources, 0).name
}