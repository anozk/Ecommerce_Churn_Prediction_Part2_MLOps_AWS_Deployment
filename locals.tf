locals {
  code_build_service_role = "arn:aws:iam::212208750479:role/service-role/churn-application-role"
  #code_commit_repo_name   = "churn-prediction"
  #code_commit_location    = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/churn-prediction"
  code_pipeline_role      = "arn:aws:iam::212208750479:role/service-role/AWSCodePipelineServiceRole-us-east-1-churn_pipeline"
  ecs_service_role        = "arn:aws:iam::212208750479:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  ecs_task_role           = "arn:aws:iam::212208750479:role/ecsTaskExecutionRole"
  vpc_id                  = "vpc-0d5534ea74dfb6a56"
  db_user      = "master"
  db_password  = var.db_password
  db_host      = ""
  db_port      = 5432
  db_name      = "postgres"
  tags = {
    application = "churn-prediction"
  }
}
