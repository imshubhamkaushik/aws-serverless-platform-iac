variable "service_names" {
  type = list(string)
}

variable "retention_days" {
  type    = number
  default = 7
}
