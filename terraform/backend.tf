
terraform {
  backend "s3" {
    bucket       = "aws-terraform-state-bucket-0011"
    key          = "cicd-apache/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true  # S3 native locking — no DynamoDB needed
  }
}

