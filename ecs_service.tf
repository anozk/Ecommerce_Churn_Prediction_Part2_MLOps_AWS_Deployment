resource "aws_ecs_service" "churn_service" {
  cluster                            = aws_ecs_cluster.churn_cluster.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  desired_count                      = 2
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  # iam_role                           = local.ecs_service_role
  launch_type                        = "FARGATE"
  name                               = "churn-service"
  platform_version                   = "LATEST"
  scheduling_strategy                = "REPLICA"
  tags                               = {}
  tags_all                           = {}
  task_definition                    = format("%s:%s", aws_ecs_task_definition.churn_definition.family, aws_ecs_task_definition.churn_definition.revision)

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = "churn-application-container"
    container_port   = 5000
    target_group_arn = aws_lb_target_group.churn_target_group.arn
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      "sg-03e6c00eae6503454",
    ]
    subnets = [
      "<subnet-id>",
      "<subnet-id>",
      "<subnet-id>",
      "<subnet-id>",
      "<subnet-id>",
      "<subnet-id>",
    ]
  }

  timeouts {}
  depends_on = [
    aws_ecs_task_definition.churn_definition,
  ]
}