# ==============================================================================
# OUTPUTS
# ==============================================================================

output "ecr_repository_url" {
  description = "ECR repository URL — used in CI/CD to push/pull images"
  value       = aws_ecr_repository.app.repository_url
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions — paste this into GitHub Secrets as AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}
