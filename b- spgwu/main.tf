//CodeCommit Repository Creation

data "aws_codecommit_repository" "spgwu_Repo" {
  repository_name = "oai-spgwu"
}


//S3 Bucket Import

data "aws_s3_bucket" "kmg" {
  bucket = "kmg-pipeline"
}

// S3 Bucket Subfolders creation

resource "aws_s3_bucket_object" "oai_spgwu" {
  bucket = data.aws_s3_bucket.kmg.id
  key    = "oai-spgwu/"
  content_type =  "application/x-directory"
}
//CodeBuild- oai-spgwu

resource "aws_codebuild_project" "spgwu" {
  name          = "oai-spgwu-terraform"
  description   = "oai-spgwu-build by terraform"
  build_timeout = "60"
  service_role  = aws_iam_role.spgwu_build.arn

  artifacts {
    name = "cache-spgwu-artifacts"
    type = "S3"
    location = "artifacts-cicd-5g"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "oai-spgwu-build-terraform"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = data.aws_codecommit_repository.spgwu_Repo.repository_name
    git_clone_depth = 1
    buildspec = "buildspec.yml"

    git_submodules_config {
      fetch_submodules = true
    }
  }
}

//CodeBuild- oai-spgwu-sonar

resource "aws_codebuild_project" "spgwu_sonar" {
  name          = "oai-spgwu-sonarbuild-terraform"
  description   = "oai-spgwu-sonarbuild by terraform"
  build_timeout = "60"
  service_role  = aws_iam_role.spgwu_sonar_build.arn

  artifacts {
    name = "cache-spgwu-sonar-artifacts"
    type = "S3"
    location = "artifacts-cicd-5g"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {

      name = "PROJECTKEY"
      value = "oai-spgwu"
      
    }
    environment_variable {

      name = "SONARCLOUD_ORG"
      value = "5gc"
      
    }
    environment_variable {

      name = "SONARCLOUD_TOKEN"
      value = "c25b3f8a421db586a2f0877ad23de273822e2d00"
      
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "oai-spgwu-sonar-build-terraform"
    }
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  source {
    type            = "CODECOMMIT"
    location = data.aws_codecommit_repository.spgwu_Repo.repository_name
    git_clone_depth = 1
    buildspec = "buildspec_sonar.yml"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}

//CodePipeline Creation

resource "aws_codepipeline" "spgwu_pipeline" {
  name     = "pipeline-oai-spgwu-terraform"
  role_arn = aws_iam_role.spgwu_pipeline_iam.arn

  artifact_store {
    location = data.aws_s3_bucket.kmg.bucket 
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact_spgwu"]

      configuration = {
        RepositoryName    = "${data.aws_codecommit_repository.spgwu_Repo.repository_name}"
        BranchName        = "main"
      }
    }
  }

  stage {
    name = "StaticScan"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts = ["SourceArtifact_spgwu"]

      configuration = {
        ProjectName      = "${aws_codebuild_project.spgwu_sonar.id}"
      }
    }
  }

  stage {
    name = "SecurityHub"

    action {
      name            = "SecurityHub"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      version         = "1"

     configuration = {
        FunctionName      = "${data.aws_lambda_function.securityhub_lambda.function_name}"
      }
    }
  }

  stage {
    name = "AdminApproval"

    action {
      name             = "Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"

      configuration = {
        NotificationArn = "${data.aws_sns_topic.notification_approval.arn}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact_spgwu"]
      version         = "1"

     configuration = {
        ProjectName      = "${aws_codebuild_project.spgwu.id}"
      }
    }
  }

  
}


//SNS Topic Import for PipelineApprovalNotification

data "aws_sns_topic" "notification_approval" {
  name = "codestar-notifications-approval-terraform"
}

//Topic Subscription for PipelineApprovalNotification



resource "aws_codestarnotifications_notification_rule" "spgwu_pipeline_approval_notification" {
  detail_type    = "FULL"
  event_type_ids = ["codepipeline-pipeline-pipeline-execution-failed","codepipeline-pipeline-pipeline-execution-started","codepipeline-pipeline-pipeline-execution-succeeded"]

  name     = "PipelineApprovalNotification_spgwu"
  resource = aws_codepipeline.spgwu_pipeline.arn

  target {
    address = data.aws_sns_topic.notification_approval.arn
  }
}

//SNS Topic Import for PipelineMailNotification

data "aws_sns_topic" "mail_approval" {
  name = "codestar-notifications-cicd-demo-terraform"
}

//Topic Subscription

resource "aws_codestarnotifications_notification_rule" "spgwu_mail_approval_notification" {
  detail_type    = "FULL"
  event_type_ids = ["codepipeline-pipeline-manual-approval-needed"]

  name     = "PipelineMailNotification_spgwu"
  resource = aws_codepipeline.spgwu_pipeline.arn

  target {
    address = data.aws_sns_topic.mail_approval.arn
  }
}