resource "cloudflare_dns_record" "cname_to_cloudfront" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  ttl     = 1
  type    = "CNAME"
  content = aws_cloudfront_distribution.markhendrix_dot_com.domain_name
  proxied = false
}

resource "aws_acm_certificate" "www_markhendrix_dot_com" {
  domain_name       = "www.markhendrix.com"
  validation_method = "DNS"
}

resource "cloudflare_dns_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.www_markhendrix_dot_com.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  ttl     = 1
  type    = each.value.type
  content = each.value.record
  proxied = false

  lifecycle {
    ignore_changes = [name, content]
  }
}

resource "aws_acm_certificate_validation" "www_markhendrix_dot_com" {
  certificate_arn = aws_acm_certificate.www_markhendrix_dot_com.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.www_markhendrix_dot_com.domain_validation_options :
  dvo.resource_record_name]
}
