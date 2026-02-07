# NOTE:
# HTTP listener only.
# HTTPS/ACM is intentionally excluded for dev scope.
# In production, ACM + HTTPS listener would be added.

# APPLICATION LOAD BALANCER
resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}

# HTTP LISTENER
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_svc.arn
  }
}

# USER SERVICE RULE
resource "aws_lb_listener_rule" "user_svc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_svc.arn
  }

  condition {
    path_pattern {
      # ADDED: /actuator/* so health checks reach the correct service
      values = ["/users*", "/users/*", "/health"]
    }
  }
}

# PRODUCT SERVICE RULE
resource "aws_lb_listener_rule" "product_svc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_svc.arn
  }

  condition {
    path_pattern {
      # ADDED: Actuator paths for product service
      values = ["/products*", "/products/*", "/health"]
    }
  }
}