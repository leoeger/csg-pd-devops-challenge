# ECS Execution Role — permite a ECS arrancar el contenedor y leer secrets
resource "aws_iam_role" "ecs_exec" {
  name               = "csgtest-ecs-exec-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  tags               = { name = "csgtest" }
}
resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role — permisos mínimos para la app (solo leer su propio secret)
resource "aws_iam_role_policy" "task_secrets" {
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_secretsmanager_secret.db_creds.arn]
    }]
  })
}