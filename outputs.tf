 output "app_url" {
   value = "https://${aws_cloudfront_distribution.redstone_gateway_cloudfront_distribution.domain_name}"
 }