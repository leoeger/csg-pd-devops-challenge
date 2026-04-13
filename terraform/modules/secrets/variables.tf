# terraform/modules/secrets/variables.tf
variable "env" {}
variable "db_password" { sensitive = true }