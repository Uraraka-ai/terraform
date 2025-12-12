variable "name" {
  type        = string
  description = "The name of the Windows App Service (Web App) to be created."
}

variable "location" {
  type        = string
  description = "The Azure region where the Windows App Service will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Windows App Service."
}

variable "app_service_plan_id" {
  type        = string
  description = "The ID of the App Service Plan that will host this Windows App Service."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Windows App Service resource."
}

variable "ip_restrictions" {
  type = list(object({
    name        = string
    ip_address  = optional(string)
    service_tag = optional(string)
    action      = string
    priority    = number
  }))
  description = "A list of IP restriction rules for the Windows App Service, allowing or denying access based on IP address or Azure service tag."
}