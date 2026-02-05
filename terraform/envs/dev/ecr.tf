resource "aws_ecr_repository" "frontend-svc" {
  name = "${var.project_name}-frontend-svc"
}

resource "aws_ecr_repository" "user_svc" {
  name = "${var.project_name}-user-svc"
}

resource "aws_ecr_repository" "product_svc" {
  name = "${var.project_name}-product-svc"
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
