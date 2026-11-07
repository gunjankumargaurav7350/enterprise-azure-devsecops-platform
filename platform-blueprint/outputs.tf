output "resource_group_ids" {
  description = "Map of all provisioned resource group IDs"
  value       = { for k, v in azurerm_resource_group.rgs : k => v.id }
}

output "vnet_topology" {
  description = "Topology map of provisioned virtual networks and address spaces"
  value = {
    for k, v in azurerm_virtual_network.vnets : k => {
      id            = v.id
      address_space = v.address_space
      subnets       = [for s in v.subnet : s.name]
    }
  }
}

output "subnet_ids" {
  description = "Map of all provisioned subnet resource IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "hub_key_vault_id" {
  description = "Resource ID of the centralized Hub Key Vault"
  value       = azurerm_key_vault.hub_kv.id
}

output "hub_key_vault_uri" {
  description = "Vault URI of the centralized Hub Key Vault"
  value       = azurerm_key_vault.hub_kv.vault_uri
}

output "central_log_analytics_workspace_id" {
  description = "Resource ID of the Central Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.central_law.id
}

output "action_group_ids" {
  description = "Map of provisioned Action Group IDs"
  value       = { for k, v in azurerm_monitor_action_group.action_groups : k => v.id }
}
