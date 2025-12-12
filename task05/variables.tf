variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
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
}

