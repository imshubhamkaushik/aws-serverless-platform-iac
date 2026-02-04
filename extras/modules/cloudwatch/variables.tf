variable "name" {
  description = "Base name for CloudWatch resources"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
