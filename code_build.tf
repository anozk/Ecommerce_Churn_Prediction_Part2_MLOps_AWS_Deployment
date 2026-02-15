
# IAM Role for CodeBuild

resource "aws_iam_role" "codebuild_role" {
  name = "topic_codebuild_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_basic_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# Give CodeBuild full access to S3 (required for CodePipeline source artifacts)
resource "aws_iam_role_policy" "codebuild_s3_full_access" {
  name = "codebuild-s3-full-access"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:*"
        Resource = "*"
      }
    ]
  })
}



# GitHub Personal Access Token variable

variable "github_token" {
  description = "GitHub Personal Access Token for CodeBuild"
  type        = string
  sensitive   = true
  default     = ""
}


# CodeBuild Source Credential (PAT)

resource "aws_codebuild_source_credential" "github" {
  server_type = "GITHUB"
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  token       = var.github_token
}


# CodeBuild Project


resource "aws_codebuild_project" "topic_codebuild" {
  name         = "topic-codebuild"
  service_role = aws_iam_role.codebuild_role.arn
  description  = "CodeBuild project triggered by CodePipeline"

  source {
    type      = "CODEPIPELINE"        # Changed from GITHUB
    buildspec = "buildspec.yaml"
  }

  artifacts {
    type = "CODEPIPELINE"             # Simple - just this line
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    # Required ENV vars for ECR push
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "<aws-account-id>"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "churn-application-repo"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/topic-codebuild"
      stream_name = "build-log"
    }
  }
}
