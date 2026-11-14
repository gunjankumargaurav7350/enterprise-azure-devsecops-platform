output "resource_group_ids" {
  description = "Map of all provisioned resource group IDs"
  value       = { for k, v in azurerm_resource_group.rgs : k => v.id }
}

output "vnet_topology" {
  description = "Topology map of provisioned virtual networks and address spaces"
  value       = module.network_mesh.vnet_topology
}

output "subnet_ids" {
  description = "Map of all provisioned subnet resource IDs"
  value       = module.network_mesh.subnet_ids
}

output "hub_key_vault_id" {
  description = "Resource ID of the centralized Hub Key Vault"
  value       = module.security_governance.hub_key_vault_id
}

output "hub_key_vault_uri" {
  description = "Vault URI of the centralized Hub Key Vault"
  value       = module.security_governance.hub_key_vault_uri
}

output "central_log_analytics_workspace_id" {
  description = "Resource ID of the Central Log Analytics Workspace"
  value       = module.platform_monitoring.central_log_analytics_workspace_id
}

output "action_group_ids" {
  description = "Map of provisioned Action Group IDs"
  value       = module.platform_monitoring.action_group_ids
}
