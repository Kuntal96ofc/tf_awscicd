//Fetching SecurityHub Lambda Function

data "aws_lambda_function" "securityhub_lambda" {
  function_name = "LambdaForSecurityHub_Terraform"
}


//PipelineApproval Notfication Lambda Function

data "aws_lambda_function" "pipelineapproval_lambda" {
  function_name = "PipelineApproval_Notification_Terraform"
}

//MailApproval Notification Lambda Function

data "aws_lambda_function" "mailapproval_lambda" {
  function_name = "MailApproval_Notification_Terraform"
}

//CloudWatch Groups

resource "aws_cloudwatch_log_group" "oai_spgwu_log" {
  name = "oai_spgwu_build"
}

resource "aws_cloudwatch_log_stream" "oai_spgwu_logstream" {
  name           = "oai_spgwu_logstream"
  log_group_name = aws_cloudwatch_log_group.oai_spgwu_log.name
}

resource "aws_cloudwatch_log_group" "oai_spgwu_sonar_log" {
  name = "oai_spgwu_sonar_build"
}

resource "aws_cloudwatch_log_stream" "oai_spgwu_sonar_logstream" {
  name           = "oai_spgwu_sonar_logstream"
  log_group_name = aws_cloudwatch_log_group.oai_spgwu_sonar_log.name
}
