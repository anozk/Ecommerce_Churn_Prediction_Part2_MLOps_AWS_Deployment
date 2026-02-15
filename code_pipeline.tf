resource "aws_codepipeline" "churn_pipeline" {
  name     = "churn_pipeline"
  role_arn = local.code_pipeline_role
  tags     = local.tags

  artifact_store {
    location = "codepipeline-us-east-1-112741295250"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      owner    = "ThirdParty"       # GitHub is ThirdParty
      provider = "GitHub"
      version  = "1"
      run_order = 1
      region   = "us-east-1"
      name     = "Source"
      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = "<GitHub username>"   # GitHub username/org
        Repo       = "Customer_Churn"   # GitHub repo name
        Branch     = "master"              # branch to track
        OAuthToken = var.github_token      # PAT from Terraform variable
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      run_order = 1
      region   = "us-east-1"
      name     = "Build"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        "ProjectName" = aws_codebuild_project.topic_codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"
      run_order = 1
      region   = "us-east-1"
      name     = "Deploy"
      input_artifacts  = ["BuildArtifact"]
      output_artifacts = []

      configuration = {
        "ClusterName" = aws_ecs_cluster.churn_cluster.name
        "ServiceName" = aws_ecs_service.churn_service.name
      }
    }
  }

  depends_on = [
    aws_ecs_service.churn_service,
  ]
}
