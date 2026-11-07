# -----------------------------------------------------------------------------
# ENTERPRISE AZURE DEVSECOPS PLATFORM - MASTER ORCHESTRATION BLUEPRINT
# Implements Hub-and-Spoke Architecture with Strict for_each Patterns
# -----------------------------------------------------------------------------

# 1. Resource Groups Orchestration (for_each)
resource "azurerm_resource_group" "rgs" {
  for_each = var.resource_groups

  name     = each.key
  location = each.value.location
  tags     = merge(var.tags, each.value.tags, { Purpose = each.value.purpose })
}

# 2. Virtual Networks Orchestration (for_each)
resource "azurerm_virtual_network" "vnets" {
  for_each = var.virtual_networks

  name                = each.key
  location            = azurerm_resource_group.rgs[each.value.resource_group_key].location
  resource_group_name = azurerm_resource_group.rgs[each.value.resource_group_key].name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = var.tags
}

# Flatten subnets into a keyed map for clean, robust for_each iteration
locals {
  subnets_flattened = merge([
    for vnet_name, vnet_data in var.virtual_networks : {
      for subnet_name, subnet_data in vnet_data.subnets :
      "${vnet_name}/${subnet_name}" => {
        vnet_name                                 = vnet_name
        subnet_name                               = subnet_name
        resource_group_name                       = azurerm_resource_group.rgs[vnet_data.resource_group_key].name
        address_prefixes                          = subnet_data.address_prefixes
        private_endpoint_network_policies_enabled = subnet_data.private_endpoint_network_policies_enabled
        service_endpoints                         = subnet_data.service_endpoints
      }
    }
  ]...)
}

# 3. Subnets Orchestration (for_each)
resource "azurerm_subnet" "subnets" {
  for_each = local.subnets_flattened

  name                                          = each.value.subnet_name
  resource_group_name                           = each.value.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnets[each.value.vnet_name].name
  address_prefixes                              = each.value.address_prefixes
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  service_endpoints                             = each.value.service_endpoints
}

# 4. Bi-Directional VNet Peering Mesh (for_each)
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

# 5. Network Security Groups with Hardened Default Baseline
resource "azurerm_network_security_group" "nsg_baseline" {
  name                = "nsg-workload-app-prod-eastus"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.rgs["rg-platform-workload-prod-eastus"].name
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

# 6. Centralized Key Vault for Platform Secrets and Encryption Keys
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "hub_kv" {
  name                        = "kv-platform-core-${var.environment}-01"
  location                    = var.primary_location
  resource_group_name         = azurerm_resource_group.rgs["rg-platform-identity-prod-eastus"].name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  public_network_access_enabled = false
  tags                        = var.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.subnets["vnet-hub-prod-eastus/snet-hub-shared-services"].id
    ]
  }
}

# 7. Centralized Log Analytics Workspace for Entire Platform
resource "azurerm_log_analytics_workspace" "central_law" {
  name                = "law-platform-central-${var.environment}-eastus"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.rgs["rg-platform-monitoring-prod-eastus"].name
  sku                 = "PerGB2018"
  retention_in_days   = 365
  tags                = var.tags
}

# 8. Operational & Security Action Groups (for_each)
resource "azurerm_monitor_action_group" "action_groups" {
  for_each = var.alert_action_recipients

  name                = each.key
  resource_group_name = azurerm_resource_group.rgs["rg-platform-monitoring-prod-eastus"].name
  short_name          = each.value.short_name
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = each.value.email_alerts
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }
}

# 9. Azure Governance: Tagging Enforcement Policy Definition
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
  resource_group_id    = azurerm_resource_group.rgs["rg-platform-workload-prod-eastus"].id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  display_name         = "Enforce Platform Tags on Workload Resource Group"
}
