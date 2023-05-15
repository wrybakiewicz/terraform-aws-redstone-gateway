 output "app_url" {
   value = aws_cloudfront_distribution.redstone_gateway_cloudfront_distribution.domain_name
 }