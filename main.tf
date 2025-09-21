#modules are the main way to package and reuse resource configurations with terraform.
resource "azurerm_resource_group" "tf-grp" {
    location = var.location
    name = "test-tf-rg"
}

resource "azurerm_route_table" "route-free" {
    location = azurerm_resource_group.tf-grp.location
    name    = "route-getfree"
    resource_group_name = azurerm_resource_group.tf-grp.name

}

resource "azurerm_route" "route1" {
    address_prefix = "10.1.0.0/16"
    name = "tfroute1"
    next_hop_type = "Internet"
    resource_group_name = azurerm_resource_group.tf-grp.name
    route_table_name = azurerm_route_table.route-free.name
}

module "vnet" {
    source = "Azure/vnet/azurerm"
    resource_group_name = azurerm_resource_group.tf-grp.name
    vnet_location = azurerm_resource_group.tf-grp.location
    version = "5.0.1"
    address_space   = ["10.0.0.0/16"]
    subnet_prefixes = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
    subnet_names    = ["subnet1","subnet2","subnet3"]
    enable_telemetry = false
    route_tables_ids = {
        subnet1 = azurerm_route_table.route-free.id
        subnet2 = azurerm_route_table.route-free.id
        subnet3 = azurerm_route_table.route-free.id
    }


    subnet_service_endpoints = {
        subnet2 = ["Microsoft.Storage","Microsoft.Sql"],
        subnet3 = ["Microsoft.AzureActiveDirectory"]
    }
    tags = {
        environment = "free"
        costcenter = "free-account"
    }
}

