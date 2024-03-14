resource "aws_route53_record" "example_record" {
  zone_id = var.hosted_zone
  name    = "asklepijes.com"
  type    = "A"

  alias {
    name                   = var.cdf_domain_name
    zone_id                = var.cdf_hosted_zone
    evaluate_target_health = false
  }
}
