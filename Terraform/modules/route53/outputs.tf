output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.nlb.arn
}

output "certificate_status" {
  description = "Status of the ACM certificate"
  value       = aws_acm_certificate.nlb.status
}

output "domain_name" {
  description = "Domain name configured"
  value       = var.domain_name
}

output "route53_record_fqdn" {
  description = "FQDN of the Route53 record"
  value       = aws_route53_record.nlb_alias.fqdn
}

output "route53_record_name" {
  description = "Name of the Route53 record"
  value       = aws_route53_record.nlb_alias.name
}

output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = var.nlb_dns_name
}