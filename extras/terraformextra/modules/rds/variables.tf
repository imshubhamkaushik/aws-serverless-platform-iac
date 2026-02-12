variable "project_name" {
  type        = string
  description = "Logical name of the project"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID for the RDS instance"
  type        = string
}