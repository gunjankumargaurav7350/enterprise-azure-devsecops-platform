output "central_log_analytics_workspace_id" {
  description = "Central Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.central_law.id
}

output "action_group_ids" {
  description = "Map of provisioned Action Group IDs"
  value       = { for k, v in azurerm_monitor_action_group.action_groups : k => v.id }
}
