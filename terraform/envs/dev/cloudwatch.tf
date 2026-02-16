# cloudwatch.tf

resource "aws_cloudwatch_log_group" "frontend_svc" {
  name              = "/ecs/frontend-svc"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "user_svc" {
  name              = "/ecs/user-svc"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "product_svc" {
  name              = "/ecs/product-svc"
  retention_in_days = 7
}

# ECS CPU Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.project_name}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.frontend_svc.name
  }

  alarm_description = "Alarm when ECS CPU exceeds 80%"
}

# ALB Unhealthy Host Alarm
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
    TargetGroup  = aws_lb_target_group.frontend_svc.arn_suffix
  }

  alarm_description = "Alarm when ALB has unhealthy hosts"
}

# CloudWatch Dashboards
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.this.name, "ServiceName", aws_ecs_service.user_svc.name]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "User Service CPU Utilization"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.this.name, "ServiceName", aws_ecs_service.product_svc.name]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Product Service CPU Utilization"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "UnhealthyHostCount", "LoadBalancer", aws_lb.this.arn_suffix, "TargetGroup", aws_lb_target_group.frontend_svc.arn_suffix]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Unhealthy Hosts"
        }
      }
    ]
  })
}