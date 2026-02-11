locals {
  # ============================================
  # Basic Components (using split and join)
  # ============================================
  naming_parts = split("-", var.naming_prefix)

  # ============================================
  # Resource Names (using join everywhere)
  # ============================================
  firewall_subnet_name   = "AzureFirewallSubnet"
  firewall_subnet_prefix = join("/", ["10.0.1.0", "26"])

  # Using join for all resource names
  public_ip_name   = join("-", concat(local.naming_parts, ["pip"]))
  firewall_name    = join("-", concat(local.naming_parts, ["afw"]))
  route_table_name = join("-", concat(local.naming_parts, ["rt"]))

  # Complex join for NSG rule name
  nsg_rule_name_parts = ["allow", "fw", "to", "lb"]
  nsg_rule_name       = join("-", concat(local.naming_parts, local.nsg_rule_name_parts))

  # ============================================
  # Firewall Configuration
  # ============================================
  firewall_sku_name = join("_", ["AZFW", "VNet"])
  firewall_sku_tier = "Standard"

  # ============================================
  # Route Names (using join)
  # ============================================
  route_name_firewall = join("-", ["route", "to", "firewall"])
  route_name_internet = join("-", ["route", "to", "internet"])

  # ============================================
  # Rule Collection Names (using join)
  # ============================================
  nat_rule_collection_name         = join("-", [var.naming_prefix, "nat", "rules"])
  network_rule_collection_name     = join("-", [var.naming_prefix, "network", "rules"])
  application_rule_collection_name = join("-", [var.naming_prefix, "app", "rules"])

  # ============================================
  # Priorities (using arithmetic)
  # ============================================
  base_priority             = 100
  nat_rule_priority         = local.base_priority
  network_rule_priority     = local.base_priority * 2
  application_rule_priority = local.base_priority * 3

  # ============================================
  # Location Processing (split, join, lower, replace)
  # ============================================
  location_parts      = split(" ", var.location)
  location_joined     = join("", local.location_parts)
  location_normalized = lower(local.location_joined)

  # ============================================
  # Service Tags (using join)
  # ============================================
  azure_cloud_prefix      = "AzureCloud"
  azure_cloud_service_tag = join(".", [local.azure_cloud_prefix, local.location_normalized])

  # ============================================
  # Ports Configuration (using toset, setunion, sort)
  # ============================================
  http_ports       = toset(["80"])
  https_ports      = toset(["443"])
  all_web_ports    = sort(tolist(setunion(local.http_ports, local.https_ports)))
  web_ports_joined = join(",", local.all_web_ports)

  # ============================================
  # Protocol Lists (using for loop)
  # ============================================
  tcp_protocols = ["TCP"]
  udp_protocols = ["UDP"]
  all_protocols = concat(local.tcp_protocols, local.udp_protocols)

  # For loop to create protocol descriptions
  protocol_descriptions = {
    for proto in local.all_protocols :
    lower(proto) => join("_", ["PROTOCOL", upper(proto)])
  }

  # ============================================
  # Container Registries (using for loop + join)
  # ============================================
  acr_base = "azurecr.io"
  mcr_base = "microsoft.com"
  cdn_base = "mscr.io"

  # Using for loop to create registry list
  registry_components = {
    acr      = local.acr_base
    mcr      = local.mcr_base
    cdn      = local.cdn_base
    data_mcr = join(".", ["mcr", local.mcr_base])
  }

  container_registries = distinct(concat(
    [join(".", ["*", local.acr_base])],
    [join(".", ["mcr", local.mcr_base])],
    [join(".", ["*", "cdn", local.cdn_base])],
    [join(".", ["*", "data", "mcr", local.mcr_base])]
  ))

  # ============================================
  # Ubuntu Mirrors (using join)
  # ============================================
  ubuntu_domain     = "ubuntu.com"
  ubuntu_subdomains = ["security", "azure.archive", "changelogs"]

  # For loop to create FQDNs
  ubuntu_mirrors = [
    for subdomain in local.ubuntu_subdomains :
    join(".", [subdomain, local.ubuntu_domain])
  ]

  # ============================================
  # Docker Registries (using for loop + join)
  # ============================================
  docker_base_domain = "docker.io"
  docker_subdomains = {
    main       = ""
    registry   = "registry-1"
    auth       = "auth"
    cloudflare = "production.cloudflare"
  }

  # For loop to create docker FQDNs
  docker_registries = [
    for key, subdomain in local.docker_subdomains :
    subdomain == "" ? local.docker_base_domain : join(".", [subdomain, local.docker_base_domain])
  ]

  # ============================================
  # Network Rules (using for loop processing)
  # ============================================
  network_rules_base = [
    {
      name           = "allow-azure-monitor"
      source         = "*"
      ports          = ["443"]
      dest_addresses = ["AzureMonitor"]
      dest_fqdns     = []
      proto          = "TCP"
    },
    {
      name           = "allow-aks-api-tcp"
      source         = "*"
      ports          = ["9000"]
      dest_addresses = [local.azure_cloud_service_tag]
      dest_fqdns     = []
      proto          = "TCP"
    },
    {
      name           = "allow-aks-api-udp"
      source         = "*"
      ports          = ["1194"]
      dest_addresses = [local.azure_cloud_service_tag]
      dest_fqdns     = []
      proto          = "UDP"
    },
  ]

  # For loop to transform network rules
  network_rules = [
    for rule in local.network_rules_base : {
      name                  = rule.name
      source_addresses      = [rule.source]
      destination_ports     = rule.ports
      destination_addresses = rule.dest_addresses
      destination_fqdns     = rule.dest_fqdns
      protocols             = [rule.proto]
    }
  ]

  # ============================================
  # Application Rules (using for loop)
  # ============================================
  application_rules = [
    {
      name             = join("-", ["allow", "container", "registries"])
      source_addresses = ["*"]
      target_fqdns     = local.container_registries
      protocols = [
        { port = element(local.all_web_ports, 1), type = "Https" }
      ]
      fqdn_tags = []
    },
    {
      name             = join("-", ["allow", "ubuntu", "updates"])
      source_addresses = ["*"]
      target_fqdns     = local.ubuntu_mirrors
      protocols = [
        { port = element(local.all_web_ports, 0), type = "Http" },
        { port = element(local.all_web_ports, 1), type = "Https" }
      ]
      fqdn_tags = []
    },
    {
      name             = join("-", ["allow", "docker", "hub"])
      source_addresses = ["*"]
      target_fqdns     = local.docker_registries
      protocols = [
        { port = element(local.all_web_ports, 1), type = "Https" }
      ]
      fqdn_tags = []
    },
  ]

  # ============================================
  # Create maps from lists (for_each ready)
  # ============================================
  network_rules_map = {
    for idx, rule in local.network_rules :
    rule.name => rule
  }

  application_rules_map = {
    for idx, rule in local.application_rules :
    rule.name => rule
  }

  # ============================================
  # Rule Names Extraction (for loop)
  # ============================================
  all_network_rule_names = [
    for rule in local.network_rules : rule.name
  ]

  all_app_rule_names = [
    for rule in local.application_rules : rule.name
  ]

  # Join all names
  network_rules_summary = join(", ", local.all_network_rule_names)
  app_rules_summary     = join(", ", local.all_app_rule_names)

  # ============================================
  # Tags (merge with for loop)
  # ============================================
  default_tags = {
    ManagedBy   = "Terraform"
    Environment = "Training"
  }

  # Process tags with for loop
  processed_tags = {
    for key, value in local.default_tags :
    key => upper(value)
  }

  combined_tags = merge(local.default_tags, var.tags)

  # ============================================
  # Useful Computations
  # ============================================
  total_network_rules = length(local.network_rules)
  total_app_rules     = length(local.application_rules)
  total_rules         = local.total_network_rules + local.total_app_rules

  # Join numbers as string
  rules_count_summary = join(" + ", [
    tostring(local.total_network_rules),
    tostring(local.total_app_rules),
    "=",
    tostring(local.total_rules)
  ])
}