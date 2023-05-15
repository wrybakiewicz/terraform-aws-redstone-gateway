locals {
  mongodb_username = "app"
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
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      provider_name = local.provider_name
      priority      = 7
      region_name   = var.mongodbatlas_region
    }
  }
}

resource "random_password" "redstone_gateway_random_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "mongodbatlas_database_user" "redstone_gateway_mongodbatlas_database_user" {
  username           = local.mongodb_username
  password           = random_password.redstone_gateway_random_password.result
  project_id         = mongodbatlas_project.redstone_gateway_mongodbatlas_project.id
  auth_database_name = "admin"

  //TODO: proper roles

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  roles {
    role_name     = "dbAdminAnyDatabase"
    database_name = "admin"
  }

}