terraform {
  required_version = ">= 1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.66"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}
