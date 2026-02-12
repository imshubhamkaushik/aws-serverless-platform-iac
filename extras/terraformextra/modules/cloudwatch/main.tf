resource "aws_cloudwatch_log_group" "ecs" {
  for_each = toset(var.service_names)

  name              = "/ecs/${each.value}"
  retention_in_days = var.retention_days
}
