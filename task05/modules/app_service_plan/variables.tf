variable "name" {
  type        = string
  description = "The name of the App Service Plan."
}

variable "location" {
  type        = string
  description = "The Azure region where the App Service Plan will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the App Service Plan."
}

variable "sku" {
  type        = string
  description = "The SKU (size) of the App Service Plan (e.g., S1)."
}

variable "worker_count" {
  type        = number
  description = "The number of workers (instances) for the App Service Plan."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the App Service Plan resource."
}