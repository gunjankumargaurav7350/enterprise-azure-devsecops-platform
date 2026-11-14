resource "azurerm_log_analytics_workspace" "central_law" {
  name                = "law-platform-central-${var.environment}-eastus"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 365
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "action_groups" {
  for_each = var.alert_action_recipients

  name                = each.key
  resource_group_name = var.resource_group_name
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
