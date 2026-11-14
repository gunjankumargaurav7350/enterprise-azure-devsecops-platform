resource "azurerm_virtual_network" "vnets" {
  for_each = var.virtual_networks

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = var.tags
}

locals {
  subnets_flattened = merge([
    for vnet_name, vnet_data in var.virtual_networks : {
      for subnet_name, subnet_data in vnet_data.subnets :
      "${vnet_name}/${subnet_name}" => {
        vnet_name                                 = vnet_name
        subnet_name                               = subnet_name
        resource_group_name                       = vnet_data.resource_group_name
        address_prefixes                          = subnet_data.address_prefixes
        private_endpoint_network_policies_enabled = subnet_data.private_endpoint_network_policies_enabled
        service_endpoints                         = subnet_data.service_endpoints
      }
    }
  ]...)
}

resource "azurerm_subnet" "subnets" {
  for_each = local.subnets_flattened

  name                                          = each.value.subnet_name
  resource_group_name                           = each.value.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnets[each.value.vnet_name].name
  address_prefixes                              = each.value.address_prefixes
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  service_endpoints                             = each.value.service_endpoints
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = var.vnet_peerings

  name                         = each.key
  resource_group_name          = azurerm_virtual_network.vnets[each.value.source_vnet_key].resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnets[each.value.source_vnet_key].name
  remote_virtual_network_id    = azurerm_virtual_network.vnets[each.value.target_vnet_key].id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}

resource "azurerm_network_security_group" "nsg_baseline" {
  name                = "nsg-workload-app-prod-eastus"
  location            = var.location
  resource_group_name = var.nsg_resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "DenyAllInboundInternet"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHubInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443", "8080"]
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}
