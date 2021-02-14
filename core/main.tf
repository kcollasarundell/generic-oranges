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


variable "deployerrole" {
  type    = string
  default = "deployer"
}


data "aws_iam_role" "deployer" {
  name = var.deployerrole
}


output "deployer_role" {
  value = data.aws_iam_role.deployer
}