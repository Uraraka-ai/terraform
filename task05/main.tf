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
  depends_on          = [module.resource_group_RG1]
}

module "app_service_plan_ASP2" {
  source              = "./modules/app_service_plan"
  name                = var.app_service_plans["ASP2"].name
  location            = var.app_service_plans["ASP2"].location
  resource_group_name = var.app_service_plans["ASP2"].resource_group_name
  sku                 = var.app_service_plans["ASP2"].sku
  worker_count        = var.app_service_plans["ASP2"].worker_count
  tags                = var.app_service_plans["ASP2"].tags
  depends_on          = [module.resource_group_RG2]
}

module "app_service_APP1" {
  source              = "./modules/app_service"
  name                = var.app_services["APP1"].name
  location            = var.app_services["APP1"].location
  resource_group_name = var.app_services["APP1"].resource_group_name
  app_service_plan_id = module.app_service_plan_ASP1.id
  tags                = var.app_services["APP1"].tags
  ip_restrictions     = var.app_services["APP1"].ip_restrictions
  depends_on          = [module.app_service_plan_ASP1]
}

module "app_service_APP2" {
  source              = "./modules/app_service"
  name                = var.app_services["APP2"].name
  location            = var.app_services["APP2"].location
  resource_group_name = var.app_services["APP2"].resource_group_name
  app_service_plan_id = module.app_service_plan_ASP2.id
  tags                = var.app_services["APP2"].tags
  ip_restrictions     = var.app_services["APP2"].ip_restrictions
  depends_on          = [module.app_service_plan_ASP2]
}

module "traffic_manager" {
  source              = "./modules/traffic_manager"
  name                = var.traffic_manager.name
  resource_group_name = var.traffic_manager.resource_group_name
  routing_method      = var.traffic_manager.routing_method
  tags                = var.traffic_manager.tags
  endpoints = {
    APP1 = {
      name               = var.traffic_manager.endpoints["APP1"].name
      target_resource_id = module.app_service_APP1.id
      priority           = var.traffic_manager.endpoints["APP1"].priority
      weight             = var.traffic_manager.endpoints["APP1"].weight
      location           = var.traffic_manager.endpoints["APP1"].location
    }
    APP2 = {
      name               = var.traffic_manager.endpoints["APP2"].name
      target_resource_id = module.app_service_APP2.id
      priority           = var.traffic_manager.endpoints["APP2"].priority
      weight             = var.traffic_manager.endpoints["APP2"].weight
      location           = var.traffic_manager.endpoints["APP2"].location
    }
  }
  depends_on = [
    module.app_service_APP1,
    module.app_service_APP2,
    module.resource_group_RG3
  ]
} 