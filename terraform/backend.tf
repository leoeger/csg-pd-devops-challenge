# terraform/backend.tf
terraform {
  backend "s3" {
    bucket         = "csg-terraform-state"
    key            = "env/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt = true
  }
}