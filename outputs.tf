output "app_url" {
  value = "https://${aws_cloudfront_distribution.redstone_gateway_cloudfront_distribution.domain_name}"
}

output "mongodb_username" {
  value = mongodbatlas_database_user.redstone_gateway_mongodbatlas_database_user.username
}

output "mongodb_password" {
  value = mongodbatlas_database_user.redstone_gateway_mongodbatlas_database_user.password
  sensitive = true
}

output "mongodb_connection_string" {
  value = local.mongodb_connection_string
  sensitive = true
}