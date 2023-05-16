output "api_url" {
  value = module.gateway.api_url
}

output "mongodb_connection_string" {
  value     = module.gateway.mongodb_connection_string
  sensitive = true
}