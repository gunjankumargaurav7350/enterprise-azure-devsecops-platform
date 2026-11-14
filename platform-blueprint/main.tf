# -----------------------------------------------------------------------------
# ENTERPRISE AZURE DEVSECOPS PLATFORM - MASTER ORCHESTRATION BLUEPRINT
# Implements Hub-and-Spoke Architecture with Modular Design and Strict for_each
# -----------------------------------------------------------------------------

# 1. Resource Groups Orchestration (for_each)
resource "azurerm_resource_group" "rgs" {
  for_each = var.resource_groups

  name     = each.key
  location = each.value.location
  tags     = merge(var.tags, each.value.tags, { Purpose = each.value.purpose })
}

# 2. Modular Network Mesh & Hardened NSG (VNet, Subnets & Peerings via for_each)
module "network_mesh" {
  source = "./modules/network_mesh"

  virtual_networks = {
    for k, v in var.virtual_networks : k => {
      resource_group_name = azurerm_resource_group.rgs[v.resource_group_key].name
      location            = azurerm_resource_group.rgs[v.resource_group_key].location
      address_space       = v.address_space
      dns_servers         = v.dns_servers
      subnets             = v.subnets
    }
  }

  vnet_peerings           = var.vnet_peerings
  nsg_resource_group_name = azurerm_resource_group.rgs["rg-platform-workload-prod-eastus"].name
  location                = var.primary_location
  tags                    = var.tags
}

# 3. Modular Platform Monitoring & Observability (for_each action groups)
module "platform_monitoring" {
  source = "./modules/platform_monitoring"

  resource_group_name     = azurerm_resource_group.rgs["rg-platform-monitoring-prod-eastus"].name
  location                = var.primary_location
  environment             = var.environment
  alert_action_recipients = var.alert_action_recipients
  tags                    = var.tags
}

# 4. Modular Security Governance (Key Vault & Policy Enforcement)
module "security_governance" {
  source = "./modules/security_governance"

  key_vault_resource_group_name = azurerm_resource_group.rgs["rg-platform-identity-prod-eastus"].name
  workload_resource_group_id    = azurerm_resource_group.rgs["rg-platform-workload-prod-eastus"].id
  location                      = var.primary_location
  environment                   = var.environment
  network_acl_subnet_ids = [
    module.network_mesh.subnet_ids["vnet-hub-prod-eastus/snet-hub-shared-services"]
  ]
  tags = var.tags
}
