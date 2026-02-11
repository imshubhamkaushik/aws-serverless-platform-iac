# ECS CLUSTER
# ECS cluster is the logical grouping for services and tasks.
# With Fargate, there are NO EC2 instances or node management.

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}

# ALB TARGET GROUPS
# Each ECS service needs its own target group.
# Target type MUST be "ip" for Fargate.

resource "aws_lb_target_group" "frontend_svc" {
  name        = "${var.project_name}-frontend-svc-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "user_svc" {
  name        = "${var.project_name}-user-svc-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
    port                = "8081"
  }
}

resource "aws_lb_target_group" "product_svc" {
  name        = "${var.project_name}-product-svc-tg"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
    port                = "8082"
  }
}

# ECS TASK DEFINITIONS
# Task Definition = blueprint for running containers.
# Execution role = ECS agent permissions (pull image, push logs)
# Task role = application permissions (empty for now)

# FRONTEND SERVICE TASK

resource "aws_ecs_task_definition" "frontend_svc" {
  family                   = "${var.project_name}-frontend-svc"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "frontend-svc"
      image = "${aws_ecr_repository.frontend_svc.repository_url}:init"

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend_svc.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# USER SERVICE TASK

resource "aws_ecs_task_definition" "user_svc" {
  family                   = "${var.project_name}-user-svc"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "user-svc"
      image = "${aws_ecr_repository.user_svc.repository_url}:init"

      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/${var.db_name}"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = var.db_password
        },
        {
          name  = "ALLOWED_ORIGINS"
          value = "*"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.user_svc.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# PRODUCT SERVICE TASK

resource "aws_ecs_task_definition" "product_svc" {
  family                   = "${var.project_name}-product-svc"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "product-svc"
      image = "${aws_ecr_repository.product_svc.repository_url}:init"

      portMappings = [
        {
          containerPort = 8082
          hostPort      = 8082
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/${var.db_name}"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = var.db_password
        },
        {
          name  = "ALLOWED_ORIGINS"
          value = "*"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.product_svc.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


# ECS SERVICES

# Service ensures desired number of tasks are running
# and integrates ECS with ALB.


# FRONTEND SERVICE

resource "aws_ecs_service" "frontend_svc" {
  name            = "frontend-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend_svc.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_svc.arn
    container_name   = "frontend-svc"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

# USER SERVICE

resource "aws_ecs_service" "user_svc" {
  name                              = "user-svc"
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.user_svc.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 90

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.user_svc.arn
    container_name   = "user-svc"
    container_port   = 8081
  }

  depends_on = [aws_lb_listener.http]
}

# PRODUCT SERVICE

resource "aws_ecs_service" "product_svc" {
  name                              = "product-svc"
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.product_svc.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 90

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.product_svc.arn
    container_name   = "product-svc"
    container_port   = 8082
  }

  depends_on = [aws_lb_listener.http]

}


