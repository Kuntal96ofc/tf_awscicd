output "iam_nrf_arn" {
  description = "ARN of IAM role for oai-nrf"
  value       = aws_iam_role.nrf_build.arn
}

output "iam_sonar_nrf_role_arn" {
  description = "ARN of IAM role for SonarScan"
  value       = aws_iam_role.nrf_sonar_build.arn
}

output "iam_for_securityhublambda_arn" {
  description = "ARN of IAM role for SecurityHubLambda"
  value       = aws_iam_role.iam_for_lambda.arn
}

output "iam_pipelineapproval_lambda_arn" {
  description = "ARN of IAM role for PipelineApprovalNotification"
  value       = aws_iam_role.iam_for_pipeline_approval.arn
}

output "iam_pipelinemail_lambda_arn" {
  description = "ARN of IAM role for PipelineMailNotification"
  value       = aws_iam_role.iam_for_mail_approval.arn
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.kmg.bucket_domain_name
}

output "nrf_pipeline_arn" {
  description = "The ARN of the oai-nrf module."
  value       = aws_codepipeline.nrf_pipeline.arn
  }

output "codecommit_repo_url" {
  value = data.aws_codecommit_repository.nrf_Repo.clone_url_http
}

output "codebuild_nrf_project_name" {
  value = aws_codebuild_project.nrf.id
}

output "codebuild_nrf_sonar_project_name" {
  value = aws_codebuild_project.nrf_sonar.id
}

output "securityhub_lambda_arn" {
  value = aws_lambda_function.securityhub_lambda.arn
}

output "pipelineapproval_lambda_arn" {
  value = aws_lambda_function.pipelineapproval_lambda.arn
}

output "mailapproval_lambda_arn" {
  value = aws_lambda_function.mailapproval_lambda.arn
}

output "AccessIDG_arn" {
  value = aws_ssm_parameter.idg.arn
}

output "AccessPWDG_arn" {
  value = aws_ssm_parameter.pwdg.arn
}



