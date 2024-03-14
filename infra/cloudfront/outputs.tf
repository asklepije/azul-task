output "cdf_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
output "cdf_hosted_zone" {
  value = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}
