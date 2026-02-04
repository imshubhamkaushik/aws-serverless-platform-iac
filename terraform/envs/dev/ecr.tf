resource "aws_ecr_repository" "frontend-svc" {
  name = "${var.project_name}-frontend-svc"
}

resource "aws_ecr_repository" "user_svc" {
  name = "${var.project_name}-user-svc"
}

resource "aws_ecr_repository" "product_svc" {
  name = "${var.project_name}-product-svc"
}
