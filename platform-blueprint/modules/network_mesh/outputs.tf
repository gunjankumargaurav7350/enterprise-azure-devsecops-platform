output "vnet_topology" {
  description = "Topology map of provisioned virtual networks and address spaces"
  value = {
    for k, v in azurerm_virtual_network.vnets : k => {
      id            = v.id
      address_space = v.address_space
      subnets       = [for s in azurerm_subnet.subnets : s.name if s.virtual_network_name == v.name]
    }
  }
}

output "subnet_ids" {
  description = "Map of all provisioned subnet resource IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_id" {
  description = "Baseline NSG ID"
  value       = azurerm_network_security_group.nsg_baseline.id
}
