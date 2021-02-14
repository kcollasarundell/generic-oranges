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


variable deployrole {
    type = string
    default =  ""
}


data "aws_iam_role" "deployer" {
  name = "deployer"
}

output "deployer_role" {
    value = data.aws_iam_role.deployer
}