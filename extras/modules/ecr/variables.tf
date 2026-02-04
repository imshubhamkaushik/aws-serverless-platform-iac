variable "repositories" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "image_scan_on_push" {
  description = "Enable image vulnerability scanning on push"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to retain per repository"
  type        = number
  default     = 20
}

variable "tags" {
  type    = map(string)
  default = {}
}
