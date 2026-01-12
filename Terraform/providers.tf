terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "tls" {}

# Kubernetes provider configuration that depends on EKS cluster
provider "kubernetes" {
  host                   = var.create_eks ? data.aws_eks_cluster.eks[0].endpoint : ""
  cluster_ca_certificate = var.create_eks ? base64decode(
    data.aws_eks_cluster.eks[0].certificate_authority[0].data
  ) : ""
  token = var.create_eks ? data.aws_eks_cluster_auth.eks[0].token : ""

  # Only configure the provider if EKS is being created
  dynamic "exec" {
    for_each = var.create_eks ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_id
      ]
    }
  }
}

# Helm provider that depends on EKS cluster
provider "helm" {
  kubernetes {
    host                   = var.create_eks ? data.aws_eks_cluster.eks[0].endpoint : ""
    cluster_ca_certificate = var.create_eks ? base64decode(
      data.aws_eks_cluster.eks[0].certificate_authority[0].data
    ) : ""
    token = var.create_eks ? data.aws_eks_cluster_auth.eks[0].token : ""
    
    # Only configure the provider if EKS is being created
    dynamic "exec" {
      for_each = var.create_eks ? [1] : []
      content {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args = [
          "eks",
          "get-token",
          "--cluster-name",
          module.eks.cluster_id
        ]
      }
    }
  }
}

# Data sources for EKS cluster (will be used after cluster creation)
data "aws_eks_cluster" "eks" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}