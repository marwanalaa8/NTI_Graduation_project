variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN from EKS"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL from EKS"
}
