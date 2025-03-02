# This Terraform configuration file provisions an ACM certificate for a domain and sets up DNS validation using Route 53.
# It creates the necessary Route 53 records for validation and validates the certificate.

resource "aws_acm_certificate" "mycert_acm" {
  domain_name       = "*.mosama.site"  # The domain name for which the certificate is requested.
  validation_method = "DNS"            # The method to validate the domain ownership.

  tags = {
    Name = "Domain Cert"               # Tag to identify the certificate.
  }
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {                         # Iterate over each domain validation option provided by ACM.
    for dvo in aws_acm_certificate.mycert_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name  # The name of the DNS record to create.
      record = dvo.resource_record_value # The value of the DNS record to create.
      type   = dvo.resource_record_type  # The type of the DNS record to create.
    }
  }

  allow_overwrite = true                # Allow overwriting existing DNS records.
  name            = each.value.name     # The name of the DNS record.
  records         = [each.value.record] # The value of the DNS record.
  ttl             = 60                  # The time-to-live for the DNS record.
  type            = each.value.type     # The type of the DNS record.
  zone_id         = var.my_domain_hostedzone_id # The ID of the hosted zone in Route 53.
}

resource "aws_acm_certificate_validation" "cert_validation" {
  timeouts {
    create = "5m"                       # Timeout for the certificate validation process.
  }
  certificate_arn         = aws_acm_certificate.mycert_acm.arn # The ARN of the ACM certificate.
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn] # The FQDNs of the validation records.
}
