variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  description = "A map of resource group definitions, each containing the name, location, and tags for the resource group."
}

variable "app_service_plans" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = string
    worker_count        = number
    tags                = map(string)
  }))
  description = "A map of App Service Plan definitions, each containing the name, location, associated resource group name, SKU, worker count, and tags for the App Service Plan."
}