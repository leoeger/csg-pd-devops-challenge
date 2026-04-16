# terraform/modules/rds/variables.tf
variable "env" {}
variable "private_subnet_ids" { 
    type = list(string) 
}
variable "sg_rds_id" {}
variable "db_password" { sensitive = true }