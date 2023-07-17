//IAM_Role Variables
variable "name" {
  description = "The name of the IAM Role."
  type        = string
  default     = ""
}

variable "role" {
  description = "The IAM Role with which IAM Policy is to be attached."
  type        = string
  default     = ""
}

variable "policy" {
  description = "The IAM Policy to be attached."
  type        = string
  default     = ""
}

//S3 Variables
variable "acl" {
  description = "The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, and bucket-owner-full-control. Defaults to private."
  type        = string
  default     = null
}

variable "bucket" {
  description = "The name of the bucket to put the file in. Alternatively, an S3 access point ARN can be specified."
  type        = string
  default     = ""
}

//Codebuild Variables
variable "buildspec" {
  type        = string
  default     = ""
  description = "Declaration to use for building the project."
}

variable "build_timeout" {
  type        = number
  default     = 60
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed"
}

variable "service_role" {
  type        = string
  default     = ""
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed"
}


variable "artifacts" {
  description = "Populates the Artifact block"
  default = {
    packaging      = "NONE"
    namespace_type = "NONE"
  }
}

variable "region" {
  description = "The region of the AWS Account"
  type        = string
  default     = "<AWSRegion>"
}