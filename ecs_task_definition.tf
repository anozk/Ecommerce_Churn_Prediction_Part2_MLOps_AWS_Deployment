resource "aws_ecs_task_definition" "churn_definition" {
  family                   = "churn-application-project-new"
  cpu                      = "1024"
  memory                   = "4096"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = local.ecs_task_role
  task_role_arn            = local.ecs_task_role

  container_definitions = jsonencode([
    {
      name  = "churn-application-container"
      image = format("%s:latest", aws_ecr_repository.churn_repo.repository_url)
      essential = true
      cpu = 0
      memoryReservation = 128

      # Pass env variables to container
      environment = [
        {
          name  = "DB_HOST"
          #value = local.db_host
        },
        {
          name  = "DB_NAME"
          #value = local.db_name
        },
        {
          name  = "DB_USER"
          #value = local.db_user
        },
        {
          name  = "DB_PASSWORD"
          #value = local.db_password
        },
        {
          name  = "DB_PORT"
          #value = tostring(local.db_port)
        },
        #{
         # name  = "ENV"
         # value = "dev"
        #}
      ]

      # ADD PORT MAPPING FOR FLASK
      portMappings = [
        { containerPort = 5000, protocol = "tcp" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/churn-application"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  depends_on = [
    aws_ecs_cluster.churn_cluster,
    aws_cloudwatch_log_group.churn_app
  ]

  tags = local.tags
}
