output "iam_amf_arn" {
  description = "ARN of IAM role for oai-amf"
  value       = aws_iam_role.amf_build.arn
}

output "iam_sonar_amf_role_arn" {
  description = "ARN of IAM role for SonarScan"
  value       = aws_iam_role.amf_sonar_build.arn
}

output "iam_for_securityhublambda_arn" {
  description = "ARN of IAM role for SecurityHubLambda"
  value       = data.aws_iam_role.iam_for_lambda.arn
}

output "iam_pipelineapproval_lambda_arn" {
  description = "ARN of IAM role for PipelineApprovalNotification"
  value       = data.aws_iam_role.iam_for_pipeline_approval.arn
}

output "iam_pipelinemail_lambda_arn" {
  description = "ARN of IAM role for PipelineMailNotification"
  value       = data.aws_iam_role.iam_for_mail_approval.arn
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name."
  value       = data.aws_s3_bucket.kmg.bucket_domain_name
}

output "amf_pipeline_arn" {
  description = "The ARN of the oai-amf module."
  value       = aws_codepipeline.amf_pipeline.arn
  }

output "codecommit_repo_url" {
  value = data.aws_codecommit_repository.amf_Repo.clone_url_http
}

output "codebuild_amf_project_name" {
  value = aws_codebuild_project.amf.id
}

output "codebuild_amf_sonar_project_name" {
  value = aws_codebuild_project.amf_sonar.id
}




