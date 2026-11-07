variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., prod, stage, dev)"
  default     = "prod"
}

variable "primary_location" {
  type        = string
  description = "Primary Azure region for Landing Zone infrastructure"
  default     = "eastus"
}

variable "secondary_location" {
  type        = string
  description = "Secondary Azure region for disaster recovery and geo-redundancy"
  default     = "centralus"
}

variable "resource_groups" {
  type = map(object({
    location = string
    purpose  = string
    tags     = map(string)
  }))
  description = "Map of enterprise resource groups deployed via for_each"
  default = {
    "rg-platform-hub-prod-eastus" = {
      location = "eastus"
      purpose  = "Central Hub Connectivity (Firewall, Bastion, Gateway)"
      tags     = { Tier = "Hub", SecurityDomain = "CoreNetwork" }
    }
    "rg-platform-identity-prod-eastus" = {
      location = "eastus"
      purpose  = "Core Security, Identity & Key Management"
      tags     = { Tier = "Security", SecurityDomain = "IAM-KMS" }
    }
    "rg-platform-monitoring-prod-eastus" = {
      location = "eastus"
      purpose  = "Centralized Log Analytics, Alerts & Observability"
      tags     = { Tier = "Operations", SecurityDomain = "Monitoring" }
    }
    "rg-platform-workload-prod-eastus" = {
      location = "eastus"
      purpose  = "Production Tier Spoke Application Workloads"
      tags     = { Tier = "Workload", SecurityDomain = "AppSpoke" }
    }
  }
}

variable "virtual_networks" {
  type = map(object({
    resource_group_key = string
    address_space      = list(string)
    dns_servers        = list(string)
    subnets = map(object({
      address_prefixes                          = list(string)
      private_endpoint_network_policies_enabled = optional(bool, true)
      service_endpoints                         = optional(list(string), [])
    }))
  }))
  description = "Enterprise Hub-and-Spoke Virtual Networks with subnets configured via for_each"
  default = {
    "vnet-hub-prod-eastus" = {
      resource_group_key = "rg-platform-hub-prod-eastus"
      address_space      = ["10.0.0.0/16"]
      dns_servers        = ["168.63.129.16"]
      subnets = {
        "AzureFirewallSubnet" = {
          address_prefixes = ["10.0.1.0/24"]
        }
        "AzureBastionSubnet" = {
          address_prefixes = ["10.0.2.0/24"]
        }
        "snet-hub-appgw" = {
          address_prefixes  = ["10.0.3.0/24"]
          service_endpoints = ["Microsoft.Web", "Microsoft.KeyVault"]
        }
        "snet-hub-shared-services" = {
          address_prefixes  = ["10.0.10.0/24"]
          service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
        }
      }
    }
    "vnet-spoke-workload-prod-eastus" = {
      resource_group_key = "rg-platform-workload-prod-eastus"
      address_space      = ["10.100.0.0/16"]
      dns_servers        = ["10.0.1.4"] # Routed through Hub Azure Firewall
      subnets = {
        "snet-workload-app" = {
          address_prefixes  = ["10.100.1.0/24"]
          service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
        }
        "snet-workload-db" = {
          address_prefixes                          = ["10.100.2.0/24"]
          private_endpoint_network_policies_enabled = true
          service_endpoints                         = ["Microsoft.Sql"]
        }
        "snet-workload-private-endpoints" = {
          address_prefixes                          = ["10.100.3.0/24"]
          private_endpoint_network_policies_enabled = true
        }
      }
    }
  }
}

variable "vnet_peerings" {
  type = map(object({
    source_vnet_key          = string
    target_vnet_key          = string
    allow_virtual_network_access = bool
    allow_forwarded_traffic      = bool
    allow_gateway_transit        = bool
    use_remote_gateways          = bool
  }))
  description = "Bi-directional VNet peering matrix managed via for_each"
  default = {
    "hub-to-workload-spoke" = {
      source_vnet_key              = "vnet-hub-prod-eastus"
      target_vnet_key              = "vnet-spoke-workload-prod-eastus"
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = true
      use_remote_gateways          = false
    }
    "workload-spoke-to-hub" = {
      source_vnet_key              = "vnet-spoke-workload-prod-eastus"
      target_vnet_key              = "vnet-hub-prod-eastus"
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
  }
}

variable "alert_action_recipients" {
  type = map(object({
    short_name   = string
    email_alerts = list(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = bool
    }))
  }))
  description = "Action Groups for operational and security alerting"
  default = {
    "ag-platform-core-ops" = {
      short_name = "CoreOps"
      email_alerts = [
        {
          name                    = "CloudPlatformLead"
          email_address           = "cloud-ops@gunjankumargaurav.com"
          use_common_alert_schema = true
        }
      ]
    }
    "ag-platform-secops-urgent" = {
      short_name = "SecOps"
      email_alerts = [
        {
          name                    = "DevSecOpsIncidentResponse"
          email_address           = "security-incident@gunjankumargaurav.com"
          use_common_alert_schema = true
        }
      ]
    }
  }
}

variable "tags" {
  type        = map(string)
  description = "Global tags applied to all platform resources"
  default = {
    Platform           = "Enterprise Azure DevSecOps Platform"
    ManagedBy          = "Terraform"
    Architect          = "Gunjan Kumar Gaurav"
    ComplianceStandard = "CIS-Azure-v2.0"
    Confidentiality    = "Highly-Confidential"
  }
}
