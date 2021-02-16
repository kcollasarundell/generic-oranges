provider "aws" {
  region = "ap-southeast-2"
  assume_role {
    role_arn = var.role
  }
}

# domain

resource "aws_route53_zone" "primary" {
  name = "generic-oranges.dev"
}

module "prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = "prod-oranges"
  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# courtesy of https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest