module "resource_group_RG1" {
  source   = "./modules/resource_group"
  name     = var.resource_groups["RG1"].name
  location = var.resource_groups["RG1"].location
  tags     = var.resource_groups["RG1"].tags
}

module "resource_group_RG2" {
  source   = "./modules/resource_group"
  name     = var.resource_groups["RG2"].name
  location = var.resource_groups["RG2"].location
  tags     = var.resource_groups["RG2"].tags
}

module "resource_group_RG3" {
  source   = "./modules/resource_group"
  name     = var.resource_groups["RG3"].name
  location = var.resource_groups["RG3"].location
  tags     = var.resource_groups["RG3"].tags
}

module "app_service_plan_ASP1" {
  source              = "./modules/app_service_plan"
  name                = var.app_service_plans["ASP1"].name
  location            = var.app_service_plans["ASP1"].location
  resource_group_name = var.app_service_plans["ASP1"].resource_group_name
  sku                 = var.app_service_plans["ASP1"].sku
  worker_count        = var.app_service_plans["ASP1"].worker_count
  tags                = var.app_service_plans["ASP1"].tags
}

module "app_service_plan_ASP2" {
  source              = "./modules/app_service_plan"
  name                = var.app_service_plans["ASP2"].name
  location            = var.app_service_plans["ASP2"].location
  resource_group_name = var.app_service_plans["ASP2"].resource_group_name
  sku                 = var.app_service_plans["ASP2"].sku
  worker_count        = var.app_service_plans["ASP2"].worker_count
  tags                = var.app_service_plans["ASP2"].tags
}

module "app_service_APP1" {
  source              = "./modules/app_service"
  name                = "cmaz-fga8r1mg-mod5-app-01"
  location            = var.resource_groups["RG1"].location
  resource_group_name = var.resource_groups["RG1"].name
  app_service_plan_id = module.app_service_plan_ASP1.id
  tags                = var.resource_groups["RG1"].tags
  ip_restrictions = [
    {
      name       = "allow-ip"
      ip_address = "18.153.146.156/32"
      action     = "Allow"
      priority   = 100
    },
    {
      name        = "allow-tm"
      service_tag = "AzureTrafficManager"
      action      = "Allow"
      priority    = 200
    }
  ]
}

module "app_service_APP2" {
  source              = "./modules/app_service"
  name                = "cmaz-fga8r1mg-mod5-app-02"
  location            = var.resource_groups["RG2"].location
  resource_group_name = var.resource_groups["RG2"].name
  app_service_plan_id = module.app_service_plan_ASP2.id
  tags                = var.resource_groups["RG2"].tags
  ip_restrictions = [
    {
      name       = "allow-ip"
      ip_address = "18.153.146.156/32"
      action     = "Allow"
      priority   = 100
    },
    {
      name        = "allow-tm"
      service_tag = "AzureTrafficManager"
      action      = "Allow"
      priority    = 200
    }
  ]
}

module "traffic_manager" {
  source              = "./modules/traffic_manager"
  name                = "cmaz-fga8r1mg-mod5-traf"
  resource_group_name = var.resource_groups["RG3"].name
  routing_method      = "Performance"
  tags                = var.resource_groups["RG3"].tags
  endpoints = {
    APP1 = {
      name               = "app1-endpoint"
      target_resource_id = module.app_service_APP1.id
      priority           = 1
      weight             = 100
      location           = var.resource_groups["RG1"].location
    }
    APP2 = {
      name               = "app2-endpoint"
      target_resource_id = module.app_service_APP2.id
      priority           = 2
      weight             = 100
      location           = var.resource_groups["RG2"].location
    }
  }
}
