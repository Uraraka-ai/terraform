variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "aks_subnet_id" {
  description = "ID of the AKS subnet"
  type        = string
}

variable "aks_loadbalancer_ip" {
  description = "Public IP address of the AKS load balancer"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
variable "aks_cluster_name" {
  description = "name of the clster"
  type        = string
}

variable "aks_nsg_name" {
  description = "Name of the AKS agent pool network security group"
  type        = string
}