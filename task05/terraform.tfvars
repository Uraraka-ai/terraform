resource_groups = {
  RG1 = {
    name     = "cmaz-fga8r1mg-mod5-rg-01"
    location = "westeurope"
    tags     = { Creator = "volodymyr_havadza@epam.com" }
  }
  RG2 = {
    name     = "cmaz-fga8r1mg-mod5-rg-02"
    location = "northeurope"
    tags     = { Creator = "volodymyr_havadza@epam.com" }
  }
  RG3 = {
    name     = "cmaz-fga8r1mg-mod5-rg-03"
    location = "uksouth"
    tags     = { Creator = "volodymyr_havadza@epam.com" }
  }
}

app_service_plans = {
  ASP1 = {
    name                = "cmaz-fga8r1mg-mod5-asp-01"
    location            = "westeurope"
    resource_group_name = "cmaz-fga8r1mg-mod5-rg-01"
    sku                 = "S1"
    worker_count        = 2
    tags                = { Creator = "volodymyr_havadza@epam.com" }
  }
  ASP2 = {
    name                = "cmaz-fga8r1mg-mod5-asp-02"
    location            = "northeurope"
    resource_group_name = "cmaz-fga8r1mg-mod5-rg-02"
    sku                 = "S1"
    worker_count        = 1
    tags                = { Creator = "volodymyr_havadza@epam.com" }
  }
}

app_services = {
  APP1 = {
    name                = "cmaz-fga8r1mg-mod5-app-01"
    location            = "westeurope"
    resource_group_name = "cmaz-fga8r1mg-mod5-rg-01"
    app_service_plan_id = "" # To be set in main.tf using module output
    tags                = { Creator = "volodymyr_havadza@epam.com" }
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
  APP2 = {
    name                = "cmaz-fga8r1mg-mod5-app-02"
    location            = "northeurope"
    resource_group_name = "cmaz-fga8r1mg-mod5-rg-02"
    app_service_plan_id = "" # To be set in main.tf using module output
    tags                = { Creator = "volodymyr_havadza@epam.com" }
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
}

traffic_manager = {
  name                = "cmaz-fga8r1mg-mod5-traf"
  resource_group_name = "cmaz-fga8r1mg-mod5-rg-03"
  routing_method      = "Performance"
  tags                = { Creator = "volodymyr_havadza@epam.com" }
  endpoints = {
    APP1 = {
      name               = "app1-endpoint"
      target_resource_id = "" # To be set in main.tf using module output
      priority           = 1
      weight             = 100
      location           = "westeurope"
    }
    APP2 = {
      name               = "app2-endpoint"
      target_resource_id = "" # To be set in main.tf using module output
      priority           = 2
      weight             = 100
      location           = "northeurope"
    }
  }
}