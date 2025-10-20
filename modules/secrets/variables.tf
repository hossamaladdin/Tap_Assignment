variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_master_password" {
  description = "Master password for the database (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
