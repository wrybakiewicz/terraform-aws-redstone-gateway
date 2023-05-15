output "app_url" {
  value = module.gateway.app_url
}

output "mongodb_username" {
  value = module.gateway.mongodb_username
}

output "mongodb_password" {
  value     = module.gateway.mongodb_password
  sensitive = true
}

output "mongodb_connection_string" {
  value     = module.gateway.mongodb_connection_string
  sensitive = true
}