variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "db_instance_identifier" {
  type        = string
  description = "RDS instance identifier"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "alarm_actions" {
  type        = list(string)
  default     = []
  description = "List of ARNs to notify when alarms trigger (SNS topics, etc.)"
}

variable "cpu_threshold" {
  type        = number
  default     = 80
  description = "CPU utilization threshold percentage for alarm"
}

variable "memory_threshold" {
  type        = number
  default     = 1073741824
  description = "Free memory threshold in bytes (default: 1GB)"
}

variable "storage_threshold" {
  type        = number
  default     = 10737418240
  description = "Free storage threshold in bytes (default: 10GB)"
}

variable "connections_threshold" {
  type        = number
  default     = 100
  description = "Database connections threshold for alarm"
}

variable "latency_threshold" {
  type        = number
  default     = 0.1
  description = "Read/Write latency threshold in seconds"
}
