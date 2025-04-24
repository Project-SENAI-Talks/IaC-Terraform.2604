resource "aws_iam_role" "app-runner-role" {
  name = "${var.app_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "build.apprunner.amazonaws.com" # Permite que o App Runner assuma essa role
      },
      Action = "sts:AssumeRole",
    }]
  })
}

resource "aws_iam_policy" "app-runner-ecr-policy" {
  name = "${var.app_name}-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:GetAuthorizationToken"
      ],
      Resource = "*"
    }]
  })
}

# Anexar a política à role
resource "aws_iam_role_policy_attachment" "app-runner-ecr-access" {
  role       = aws_iam_role.app-runner-role.name
  policy_arn = aws_iam_policy.app-runner-ecr-policy.arn
}

resource "aws_apprunner_service" "app-runner" {
  service_name = "example"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app-runner-role.arn
    }
    image_repository {
      image_configuration {
        port = "8000"
      }
      image_identifier      = "861833468094.dkr.ecr.us-east-1.amazonaws.com/${var.app_name}-repo:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "example-apprunner-service"
  }
}
