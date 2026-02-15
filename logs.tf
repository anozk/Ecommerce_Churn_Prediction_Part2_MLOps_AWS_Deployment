# logs.tf
resource "aws_cloudwatch_log_group" "churn_app" {
  name              = "/ecs/churn-application"
  retention_in_days = 14
  tags              = local.tags
}
