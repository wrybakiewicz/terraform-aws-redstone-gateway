output "api_url" {
  value = "https://${aws_cloudfront_distribution.redstone_gateway_cloudfront_distribution.domain_name}"
}

output "mongodb_connection_string" {
  value     = local.mongodb_connection_string
  sensitive = true
}