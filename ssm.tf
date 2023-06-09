locals {
  ssm_prefix = "redstone/gateway/mongodb"
}

resource "aws_ssm_parameter" "ssm_param_connection_string" {
  name        = "/${local.ssm_prefix}/connection_string"
  description = "MongoDb connection string"
  type        = "SecureString"
  value       = local.mongodb_connection_string
}

resource "aws_ssm_parameter" "ssm_param_api_key_for_access_to_admin_routes" {
  name        = "/${local.ssm_prefix}/api_key_for_access_to_admin_routes"
  description = "API key for access to admin routes"
  type        = "SecureString"
  value       = var.admin_routes_api_key
}
