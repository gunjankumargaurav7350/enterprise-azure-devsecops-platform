data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "hub_kv" {
  name                          = "kv-platform-core-${var.environment}-01"
  location                      = var.location
  resource_group_name           = var.key_vault_resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "premium"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = var.network_acl_subnet_ids
  }
}

resource "azurerm_policy_definition" "require_tags" {
  name         = "policy-require-mandatory-platform-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Enforce Mandatory Platform Governance Tags"
  description  = "Denies resource creation if mandatory platform compliance tags are missing"

  metadata = jsonencode({
    category = "Governance"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "tags['Platform']"
          exists = "false"
        },
        {
          field  = "tags['Architect']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "enforce_tags" {
  name                 = "assign-enforce-platform-tags"
  resource_group_id    = var.workload_resource_group_id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  display_name         = "Enforce Platform Tags on Workload Resource Group"
}
