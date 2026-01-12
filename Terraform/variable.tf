variable "create_eks" {
  type        = bool
  description = "Controls if EKS resources should be created"
  default     = true
}

variable "region" {
  type    = string
  default = "eu-central-1"
}
variable "project_name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "my-eks"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default = [
    "192.168.0.0/18",
    "192.168.64.0/18"
  ]
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default = [
    "192.168.128.0/18",
    "192.168.192.0/18"
  ]
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}
variable "cluster_name" {
  type        = string
  default = "my-eks"
  description = "EKS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = ""
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS worker nodes"
  default     = []
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "Public subnet IDs for EKS load balancers"
  default     = []
}

variable "eks_version" {
  type        = string
  default     = "1.34"
}

variable "node_group_name" {
  type        = string
  default     = "eks-workers"
}

variable "node_group_instance_types" {
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_capacity" {
  type        = number
  default     = 2
}

variable "max_capacity" {
  type        = number
  default     = 3
}

variable "min_capacity" {
  type        = number
  default     = 2
}
variable "secret_name" {
  description = "Name of the secret"
  type        = string
  default = "my-db-secret-test"
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = "Database credentials"
}

variable "secret_values" {
  description = "Key-value map to store as secret"
  type        = map(string)
}

variable "tags" {
  description = "Tags for the secret"
  type        = map(string)
  default     = {
    Environment = "production"
  }
}