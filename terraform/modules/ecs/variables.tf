# terraform/modules/ecs/variables.tf
variable "env" {}
variable "image_url" {}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "sg_alb_id" {}
variable "sg_ecs_id" {}
variable "db_secret_arn" {}