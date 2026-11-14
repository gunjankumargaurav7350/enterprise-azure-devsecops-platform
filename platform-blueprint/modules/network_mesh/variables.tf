variable "virtual_networks" {
  type = map(object({
    resource_group_name = string
    location            = string
    address_space       = list(string)
    dns_servers         = list(string)
    subnets = map(object({
      address_prefixes                          = list(string)
      private_endpoint_network_policies_enabled = optional(bool, true)
      service_endpoints                         = optional(list(string), [])
    }))
  }))
  description = "Virtual networks with subnets managed via for_each"
}

variable "vnet_peerings" {
  type = map(object({
    source_vnet_key              = string
    target_vnet_key              = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  }))
  description = "Bi-directional VNet peerings managed via for_each"
  default     = {}
}

variable "nsg_resource_group_name" {
  type        = string
  description = "Resource Group for default NSG baseline"
}

variable "location" {
  type        = string
  description = "Azure Region for NSG"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
