variable "key_vault_resource_group_name" {
  type        = string
  description = "Resource Group Name for Key Vault"
}

variable "workload_resource_group_id" {
  type        = string
  description = "Target Resource Group ID for Policy Assignment"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "environment" {
  type        = string
  description = "Environment tier"
}

variable "network_acl_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for Key Vault network ACLs"
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
}
