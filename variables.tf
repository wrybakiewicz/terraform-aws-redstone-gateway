variable "admin_routes_api_key" {
  description = "API key for admin routes in gateway service."
}

# Examples of valid MongoDb Atlas regions: https://docs.atlas.mongodb.com/reference/amazon-aws/
variable "mongodbatlas_region" {
  description = "MongoDB Atlas region that should correspond with AWS region."
}