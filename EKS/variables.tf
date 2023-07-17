# AWS Settings
variable "region" {
  description = "Region in which infrastructure will be deployed"
  type        = string
}

variable "access_key" {
  description = "Access Key for the IAM Account"
  type        = string
}

variable "secret_key" {
  description = "Secret key for the IAM Account"
  type        = string
}

variable "vpc_id" {}

variable "subnetid2" {}

variable "subnetid1" {}

variable "subnetid3" {}

variable "eks_iam_role" {}