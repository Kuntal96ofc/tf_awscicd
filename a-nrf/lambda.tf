//SecurityHub Lambda Function

resource "aws_lambda_function" "securityhub_lambda" {
  filename      = "SecurityHub.zip"
  function_name = "LambdaForSecurityHub_Terraform"
  role          = aws_iam_role.iam_for_lambda.arn
  source_code_hash = filebase64sha256("SecurityHub.zip")
  runtime = "python3.6"
  handler = "lambda_function.lambda_handler"
  timeout = "603"
}


//PipelineApproval Notfication Lambda Function

resource "aws_lambda_function" "pipelineapproval_lambda" {
  filename      = "./PipelineApproval.zip"
  function_name = "PipelineApproval_Notification_Terraform"
  role          = aws_iam_role.iam_for_pipeline_approval.arn
  source_code_hash = filebase64sha256("./PipelineApproval.zip")
  runtime = "python3.6"
  handler = "lambda_function.lambda_handler"
  timeout = "603"
}

//MailApproval Notification Lambda Function

resource "aws_lambda_function" "mailapproval_lambda" {
  filename      = "./MailApproval.zip"
  function_name = "MailApproval_Notification_Terraform"
  role          = aws_iam_role.iam_for_mail_approval.arn
  source_code_hash = filebase64sha256("./MailApproval.zip")
  runtime = "python3.6"
  handler = "lambda_function.lambda_handler"
  timeout = "603"
}

//CloudWatch Groups

resource "aws_cloudwatch_log_group" "oai_nrf_log" {
  name = "oai_nrf_build"
}

resource "aws_cloudwatch_log_stream" "oai_nrf_logstream" {
  name           = "oai_nrf_logstream"
  log_group_name = aws_cloudwatch_log_group.oai_nrf_log.name
}

resource "aws_cloudwatch_log_group" "oai_nrf_sonar_log" {
  name = "oai_nrf_sonar_build"
}

resource "aws_cloudwatch_log_stream" "oai_nrf_sonar_logstream" {
  name           = "oai_nrf_sonar_logstream"
  log_group_name = aws_cloudwatch_log_group.oai_nrf_sonar_log.name
}
