# terraform/enviroments/prod/variables.tf
variable "db_password" { sensitive = true }
variable "image_url" {}