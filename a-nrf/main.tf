//CodeCommit Repository Creation

data "aws_codecommit_repository" "nrf_Repo" {
  repository_name = "oai-nrf"
}


//S3 Bucket Creation

resource "aws_s3_bucket" "kmg" {
  bucket = "kmg-pipeline"
  acl    = "private"
  force_destroy = true
}

//CodeBuild- oai-nrf

resource "aws_codebuild_project" "nrf" {
  name          = "oai-nrf-terraform"
  description   = "oai-nrf-build by terraform"
  build_timeout = "60"
  service_role  = aws_iam_role.nrf_build.arn

  artifacts {
    name = "cache-nrf-artifacts"
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
      group_name  = "oai-nrf-build-terraform"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = data.aws_codecommit_repository.nrf_Repo.repository_name
    git_clone_depth = 1
    buildspec = "buildspec.yml"

    git_submodules_config {
      fetch_submodules = true
    }
  }
}

//CodeBuild- oai-nrf-sonar

resource "aws_codebuild_project" "nrf_sonar" {
  name          = "oai-nrf-sonarbuild-terraform"
  description   = "oai-nrf-sonarbuild by terraform"
  build_timeout = "60"
  service_role  = aws_iam_role.nrf_sonar_build.arn

  artifacts {
    name = "cache-nrf-sonar-artifacts"
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
      value = "oai-nrf"
      
    }
    environment_variable {

      name = "SONARCLOUD_ORG"
      value = "demo"
      
    }
    environment_variable {

      name = "SONARCLOUD_TOKEN"
      value = "<SONARCLOUD_TOKEN>"
      
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "oai-nrf-sonar-build-terraform"
    }
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  source {
    type            = "CODECOMMIT"
    location = data.aws_codecommit_repository.nrf_Repo.repository_name
    git_clone_depth = 1
    buildspec = "buildspec_sonar.yml"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}

//CodePipeline Creation

resource "aws_codepipeline" "nrf_pipeline" {
  name     = "pipeline-oai-nrf-terraform"
  role_arn = aws_iam_role.nrf_pipeline_iam.arn

  artifact_store {
    location = aws_s3_bucket.kmg.bucket
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
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName    = "${data.aws_codecommit_repository.nrf_Repo.repository_name}"
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
      input_artifacts = ["SourceArtifact"]

      configuration = {
        ProjectName      = "${aws_codebuild_project.nrf_sonar.id}"
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
        FunctionName      = "${aws_lambda_function.securityhub_lambda.function_name}"
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
        NotificationArn = "${aws_sns_topic.notification_approval.arn}"
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
      input_artifacts = ["SourceArtifact"]
      version         = "1"

     configuration = {
        ProjectName      = "${aws_codebuild_project.nrf.id}"
      }
    }
  }

  
}


//SNS Topic Creation for PipelineApprovalNotification

resource "aws_sns_topic" "notification_approval" {
  name            = "codestar-notifications-approval-terraform"
  policy = <<EOT
 {
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "CodeNotification_publish",
      "Effect": "Allow",
      "Principal": {
        "Service": "codestar-notifications.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:<AWSRegion>:<AWSAccountNumber>:codestar-notifications-approval-terraform"
    }
  ]
}
 EOT
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}


//Topic Subscription for PipelineApprovalNotification

resource "aws_sns_topic_subscription" "notification_approval_subscription" {
  topic_arn = aws_sns_topic.notification_approval.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.pipelineapproval_lambda.arn
}


resource "aws_codestarnotifications_notification_rule" "pipeline_approval_notification" {
  detail_type    = "FULL"
  event_type_ids = ["codepipeline-pipeline-pipeline-execution-failed","codepipeline-pipeline-pipeline-execution-started","codepipeline-pipeline-pipeline-execution-succeeded"]

  name     = "PipelineApprovalNotification"
  resource = aws_codepipeline.nrf_pipeline.arn

  target {
    address = aws_sns_topic.notification_approval.arn
  }
}

//SNS Topic Creation for PipelineMailNotification

resource "aws_sns_topic" "mail_approval" {
  name            = "codestar-notifications-cicd-demo-terraform"
  policy = <<EOT
 {
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "CodeNotification_publish",
      "Effect": "Allow",
      "Principal": {
        "Service": "codestar-notifications.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:<AWSRegion>:<AWSAccountNumber>:codestar-notifications-cicd-demo-terraform"
    }
  ]
}
 EOT
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}


//Topic Subscription

resource "aws_sns_topic_subscription" "mail_approval_subscription" {
  topic_arn = aws_sns_topic.mail_approval.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.mailapproval_lambda.arn
}


resource "aws_codestarnotifications_notification_rule" "mail_approval_notification" {
  detail_type    = "FULL"
  event_type_ids = ["codepipeline-pipeline-manual-approval-needed"]

  name     = "PipelineMailNotification"
  resource = aws_codepipeline.nrf_pipeline.arn

  target {
    address = aws_sns_topic.mail_approval.arn
  }
}

//SSM Parameters Creation

resource "aws_ssm_parameter" "idg" {
  name  = "AccessIDG_Terraform"
  type  = "SecureString"
  value = "AKIA2WPEKM37OIY26RU2"
}

resource "aws_ssm_parameter" "pwdg" {
  name  = "AccessPWDG_Terraform"
  type  = "SecureString"
  value = "<SecureStringValue"
}