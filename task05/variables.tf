variable "resource_groups" {
  description = "A map of resource group definitions, each containing the name, location, and tags for the resource group."
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
}

variable "app_service_plans" {
  description = "A map of App Service Plan definitions, each containing the name, location, associated resource group name, SKU, worker count, and tags for the App Service Plan."
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = string
    worker_count        = number
    tags                = map(string)
  }))
}

variable "app_services" {
  description = "A map of App Service definitions, each containing the name, location, resource group, plan ID, tags, and IP restrictions."
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    app_service_plan_id = string
    tags                = map(string)
    ip_restrictions = list(object({
      name        = string
      ip_address  = optional(string)
      service_tag = optional(string)
      action      = string
      priority    = number
    }))
  }))
}

variable "traffic_manager" {
  description = "Traffic Manager profile configuration including name, resource group, routing method, tags, and endpoints."
  type = object({
    name                = string
    resource_group_name = string
    routing_method      = string
    tags                = map(string)
    endpoints = map(object({
      name               = string
      target_resource_id = string
      priority           = number
      weight             = number
      location           = string
    }))
  })
}