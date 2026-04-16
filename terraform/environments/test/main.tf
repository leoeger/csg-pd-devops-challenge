# terraform/enviroments/test/main.tf
terraform {
  backend "s3" {
    bucket = "csgtest-tfstate"
    key    = "test/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" { region = "us-east-1" }

module "networking" {
  source   = "../../modules/networking"
  env      = "test"
  vpc_cidr = "10.0.0.0/16"
}

module "secrets" {
  source      = "../../modules/secrets"
  env         = "test"
  db_password = var.db_password
}

module "rds" {
  source             = "../../modules/rds"
  env                = "test"
  private_subnet_ids = module.networking.public_subnet_ids
  sg_rds_id          = module.networking.sg_rds_id
  db_password        = var.db_password
}

module "ecs" {
  source            = "../../modules/ecs"
  env               = "test"
  image_url         = var.image_url
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  sg_alb_id         = module.networking.sg_alb_id
  sg_ecs_id         = module.networking.sg_ecs_id
  db_secret_arn     = module.secrets.secret_arn
}

output "app_url" { value = "http://${module.ecs.alb_dns}" }