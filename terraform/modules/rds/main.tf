# terraform/modules/rds/main.tf
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-${var.env}"
  subnet_ids = var.private_subnet_ids
  tags       = { name = "csgtest" }
}

resource "aws_db_instance" "main" {
  identifier           = "rds-${var.env}"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = var.env == "prod" ? "db.t3.small" : "db.t3.micro"
  allocated_storage    = 20
  db_name              = "appdb"
  username             = "dbadmin"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_rds_id]
  skip_final_snapshot  = true
  multi_az             = var.env == "prod" ? true : false
  tags                 = { name = "csgtest" }
}

output "db_endpoint" { value = aws_db_instance.main.endpoint }