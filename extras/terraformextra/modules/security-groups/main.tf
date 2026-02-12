resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_services" {
  name   = "${var.project_name}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for Catalogix PostgreSQL database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_services.id]
  }

  # Better to keep egress here as it rarely changes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # Standalone "Handshake" Rule for RDS
# resource "aws_vpc_security_group_ingress_rule" "ecs_to_rds" {
#   security_group_id = aws_security_group.rds.id
#   description       = "Allow PostgreSQL access from ECS tasks"

#   from_port   = 5432
#   to_port     = 5432
#   ip_protocol = "tcp"

#   # The Source Handshake
#   referenced_security_group_id = aws_security_group.ecs_service.id
# }