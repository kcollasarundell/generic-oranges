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
  source = "./vpc"
}