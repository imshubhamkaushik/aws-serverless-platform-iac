resource "aws_cloudwatch_log_group" "frontend_svc" {
  name              = "/ecs/frontend-svc"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "user_svc" {
  name              = "/ecs/user-svc"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "product_svc" {
  name              = "/ecs/product-svc"
  retention_in_days = 14
}
