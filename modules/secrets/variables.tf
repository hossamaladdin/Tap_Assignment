variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "db_master_username" {
  type = string
}

variable "db_master_password" {
  type    = string
  default = ""
}
