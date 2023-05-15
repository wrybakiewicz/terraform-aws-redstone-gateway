module "gateway" {
  source               = "../../"
  admin_routes_api_key = "example-key"
  mongodbatlas_region  = "EU_CENTRAL_1"
}