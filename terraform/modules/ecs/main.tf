# terraform/modules/ecs/main.tf
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = { name = "csgtest" }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "secrets_access" {
  role = aws_iam_role.ecs_task_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [var.db_secret_arn]
    }]
  })
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/app-${var.env}"
  retention_in_days = 7
  tags              = { name = "csgtest" }
}

resource "aws_ecs_cluster" "main" {
  name = "cluster-${var.env}"
  tags = { name = "csgtest" }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([{
    name         = "app"
    image        = var.image_url
    portMappings = [{ containerPort = 80 }]
    environment  = [{ name = "ENVIRONMENT", value = var.env }]
    secrets      = [{ name = "DB_PASSWORD", valueFrom = "${var.db_secret_arn}:password::" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/app-${var.env}"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
  tags = { name = "csgtest" }
}

resource "aws_lb" "main" {
  name               = "alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids
  tags               = { name = "csgtest" }
}

resource "aws_lb_target_group" "app" {
  name        = "tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/" }
  tags = { name = "csgtest" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_ecs_service" "app" {
  name            = "service-${var.env}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.env == "prod" ? 2 : 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.sg_ecs_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http]
  tags       = { name = "csgtest" }
}

output "alb_dns" { value = aws_lb.main.dns_name }