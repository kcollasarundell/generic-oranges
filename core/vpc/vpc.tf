# domain

resource "aws_route53_zone" "primary" {
  name = "generic-oranges.dev"
}

# This upstream module is maintained by a aws community hero and the automates a large amount of the details involved in a vpc
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
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

module "dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev-oranges"
  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
