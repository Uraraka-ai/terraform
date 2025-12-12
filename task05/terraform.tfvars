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