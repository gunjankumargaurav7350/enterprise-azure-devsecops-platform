variable "resource_group_name" {
  type        = string
  description = "Resource Group Name for Monitoring"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "environment" {
  type        = string
  description = "Environment tier"
}

variable "alert_action_recipients" {
  type = map(object({
    short_name = string
    email_alerts = list(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = optional(bool, true)
    }))
  }))
  description = "Alert action groups configured via for_each"
  default     = {}
}

variable "tags" {
  type        = map(string)
  default     = {}
}
