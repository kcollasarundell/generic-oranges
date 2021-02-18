terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    key    = "app/state"
    region = "ap-southeast-2"
  }
}

# In real use this should be feeding into a count and a loop so that we can handle multiple matching VPCs
data "aws_vpcs" "prod_oranges" {
  tags = {
    environment = "production"
  }
}

data "aws_subnet_ids" "prod_oranges" {
  vpc_id = aws_vpcs.prod_oranges.ids
}

data "aws_subnet" "prod_oranges" {
  for_each = data.aws_subnet_ids.prod_oranges.ids
  id       = each.value
}

