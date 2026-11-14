output "hub_key_vault_id" {
  description = "Resource ID of the centralized Hub Key Vault"
  value       = azurerm_key_vault.hub_kv.id
}

output "hub_key_vault_uri" {
  description = "Vault URI of the centralized Hub Key Vault"
  value       = azurerm_key_vault.hub_kv.vault_uri
}

output "policy_definition_id" {
  description = "Policy Definition ID"
  value       = azurerm_policy_definition.require_tags.id
}

output "policy_assignment_id" {
  description = "Policy Assignment ID"
  value       = azurerm_resource_group_policy_assignment.enforce_tags.id
}
