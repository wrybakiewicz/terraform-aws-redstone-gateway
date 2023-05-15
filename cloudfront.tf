locals {
  aws_managed_caching_disabled_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

data "aws_cloudfront_cache_policy" "aws_cloudfront_cache_policy" {
  id = local.aws_managed_caching_disabled_policy_id
}

resource "aws_cloudfront_distribution" "redstone_gateway_cloudfront_distribution" {
  origin {
    domain_name              = aws_lb.redstone_gateway_loadbalancer.dns_name
    origin_id                = aws_lb.redstone_gateway_loadbalancer.dns_name

    custom_origin_config {
      http_port              = local.app_port
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = aws_lb.redstone_gateway_loadbalancer.dns_name
    cache_policy_id        = data.aws_cloudfront_cache_policy.aws_cloudfront_cache_policy.id
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}