terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    key    = "core/state"
    region = "ap-southeast-2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}


module "role" {
  source = "./role"
}



module "compute" {
  source     = "./vpc"
  depends_on = [module.role]
}

module "app" {
  source = "./app"
}

output "name_servers" {
  value = module.compute.name_servers
}