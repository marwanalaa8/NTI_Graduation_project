terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}

# Argo CD Helm release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = var.create_namespace

  set {
    name  = "server.admin.password"
    value = var.argocd_admin_password
  }

  set {
    name  = "server.resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "1Gi"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
  # Expose ArgoCD server via an ALB Ingress (not a Service LoadBalancer)
  # Make the server a ClusterIP and enable the chart-managed Ingress with ALB annotations
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  # Hostname for ArgoCD UI (defaults to argocd.<zone>)
  set {
    name  = "server.ingress.hosts[0].host"
    value = "argocd.${var.route53_zone_name}"
  }

  # Ingress annotations for AWS ALB (requires AWS Load Balancer Controller in cluster)
  set {
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "alb"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internet-facing"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "ip"
  }
}

# kube-prometheus-stack (Prometheus + Grafana)
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = var.create_namespace

  set {
    name  = "prometheusOperator.createCustomResource"
    value = "true"
  }

  set {
    name  = "prometheusOperator.admissionWebhooks.enabled"
    value = "true"
  }

  set {
    name  = "prometheusOperator.createPrometheusRules"
    value = "true"
  }

  # install CRDs if supported by the chart
  # (already set above using a multi-line block) - removed duplicate single-line block
}

# ingress-nginx
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.ingress_namespace
  create_namespace = var.create_namespace

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  # Expose the ingress controller with a Service LoadBalancer and force NLB type
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  # Set a predictable load balancer name so Terraform can look it up via the AWS provider
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = local.lb_name
  }
}

# external-secrets
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://external-secrets.github.io/kubernetes-external-secrets/"
  chart      = "kubernetes-external-secrets"
  namespace  = "external-secrets"
  create_namespace = var.create_namespace
}

# metrics-server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  create_namespace = false
}

locals {
  lb_name = var.lb_name != "" ? lower(var.lb_name) : lower("${var.project_name}-ingress-nlb")
}

# Lookup the AWS Network Load Balancer created for the ingress by name
data "aws_lb" "ingress" {
  name = local.lb_name
  # ensure the lookup happens after the helm_release creates the Service / LB
  depends_on = [helm_release.nginx_ingress]
  
}

# Lookup Route53 zone only when user didn't provide the zone id
data "aws_route53_zone" "zone" {
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "ingress_alias" {
  zone_id = var.route53_zone_id != "" ? var.route53_zone_id : data.aws_route53_zone.zone.zone_id
  name    = var.route53_record_name != "" ? var.route53_record_name : var.route53_zone_name
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress.dns_name
    zone_id                = data.aws_lb.ingress.zone_id
    evaluate_target_health = false
  }
}
