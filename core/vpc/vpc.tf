# domain configuration
resource "aws_route53_zone" "primary" {
  name = "generic-oranges.dev"
}

output "name_servers" {
  value = aws_route53_zone.primary.name_servers
}

# This upstream module is maintained by a aws community hero and the automates a large amount of the details involved in a vpc
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = "prod-oranges"
  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-2a", ]
  public_subnets = ["10.0.101.0/24", ]
  public_subnet_tags = {
    tier = "public"
  }
  private_subnet_tags = {
    tier = "private"
  }
  private_subnets = ["10.0.1.0/24", ]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

module "dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev-oranges"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-2a", ]
  public_subnets  = ["10.0.101.0/24", ]
  private_subnets = ["10.0.1.0/24", ]
  public_subnet_tags = {
    build = true
    tier  = "public"
  }
  private_subnet_tags = {
    tier = "private"
  }

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  private_subnet_assign_ipv6_address_on_creation = false


  public_subnet_ipv6_prefixes  = [0]
  private_subnet_ipv6_prefixes = [3]
  enable_nat_gateway           = true
  single_nat_gateway           = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
