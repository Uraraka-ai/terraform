variable "name" {
  type        = string
  description = "The name of the Traffic Manager profile."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Traffic Manager profile."
}

variable "routing_method" {
  type        = string
  description = "The routing method for the Traffic Manager profile (e.g., Performance)."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Traffic Manager profile."
}

variable "endpoints" {
  type = map(object({
    name               = string
    target_resource_id = string
    priority           = number
    weight             = number
    location           = string
  }))
  description = "A map of endpoint definitions for the Traffic Manager profile."
}