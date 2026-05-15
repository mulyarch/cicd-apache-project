variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cicd-apache"
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "cicd-apache-project"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state (used in IAM policy)"
  type        = string
  default     = "aws-terraform-state-bucket-0011"
}
