variable "aws_account" {
  description = "Name of the AWS Account to connect to"
  type        = string
  default = "main-01"
}

variable "aws_region" {
  description = "AWS region to connect to"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Select instance environment PROD_PILOT | PROD_STAGING | PRODUCTION | PREPROD_PILOT | PREPROD"
  type        = string
  default = "PREPROD"
}

variable "certificate_arn" {
  description = "Certificate for a domain omega-next.online"
  type        = string
  sensitive   = true
}