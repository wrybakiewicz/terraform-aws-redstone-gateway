locals {
  mongodb_username = "app"
  mongodb_database_name = "redstoneGatewayDb"

  mongodb_connection_string_prefix = "mongodb+srv://"
  mongodb_connection_string_from_resource = mongodbatlas_advanced_cluster.redstone_gateway_mongodbatlas_cluster.connection_strings[0].standard_srv
  mongodb_connection_string_prefix_with_credentials = "${local.mongodb_connection_string_prefix}${mongodbatlas_database_user.redstone_gateway_mongodbatlas_database_user.username}:${nonsensitive(mongodbatlas_database_user.redstone_gateway_mongodbatlas_database_user.password)}@"
  mongodb_connection_string = "${replace(local.mongodb_connection_string_from_resource, local.mongodb_connection_string_prefix, local.mongodb_connection_string_prefix_with_credentials)}/${local.mongodb_database_name}"
}

data "aws_caller_identity" "aws_current_identity" {}

data "mongodbatlas_roles_org_id" "redstone_gateway_mongodbatlas_roles_org_id" {
}

resource "mongodbatlas_project" "redstone_gateway_mongodbatlas_project" {
  name   = "Redstone Gateway"
  org_id = data.mongodbatlas_roles_org_id.redstone_gateway_mongodbatlas_roles_org_id.org_id
}

resource "mongodbatlas_advanced_cluster" "redstone_gateway_mongodbatlas_cluster" {
  project_id   = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  name         = "gateway-cluster"
  cluster_type = "REPLICASET"
  mongo_db_major_version = "6.0"
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      auto_scaling {
        disk_gb_enabled = true
      }
      provider_name = local.provider_name
      priority      = 7
      region_name   = var.mongodbatlas_region
    }
  }
}

resource "random_password" "redstone_gateway_random_password" {
  length           = 32
  special          = false
}

resource "mongodbatlas_database_user" "redstone_gateway_mongodbatlas_database_user" {
  username           = local.mongodb_username
  password           = random_password.redstone_gateway_random_password.result
  project_id         = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = local.mongodb_database_name
  }
}