resource "aws_cloudwatch_log_group" "eks_app_logs" {
  name              = "/eks/${var.name}/application"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "app_error_count" {
  name           = "${var.name}-app-error-count"
  log_group_name = aws_cloudwatch_log_group.eks_app_logs.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "ApplicationErrorCount"
    namespace = "Catalogix/Application"
    value     = "1"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "app_error_alarm" {
  alarm_name          = "${var.name}-application-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApplicationErrorCount"
  namespace           = "Catalogix/Application"
  period              = 300
  statistic           = "Sum"
  threshold           = 5

  alarm_description = "Application is logging too many errors"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", var.name]
          ]
          period = 300
          stat   = "Maximum"
          region = "ap-south-1"
          title  = "EKS Failed Node Count"
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6

        properties = {
          metrics = [
            ["Catalogix/Application", "ApplicationErrorCount"]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-south-1"
          title  = "Application Error Count"
        }
      }
    ]
  })
}
