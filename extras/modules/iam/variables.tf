variable "name" {
  description = "Base name for IAM resources"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
  default     = null
}

variable "service_account_namespace" {
  description = "Kubernetes namespace for IRSA"
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "Kubernetes service account name for IRSA"
  type        = string
  default     = null
}

variable "policy_json" {
  description = "IAM policy JSON for IRSA role"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "name" {
  description = "IAM role name"
  type        = string
}

variable "assume_role_policy" {
  description = "Assume role policy JSON"
  type        = string
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

