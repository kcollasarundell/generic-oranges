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
provider "aws" {
  region = "ap-southeast-2"
}



# In real use this should be feeding into a count and a loop so that we can handle multiple matching VPCs or a set of modules
data "aws_vpcs" "prod_oranges" {
  tags = {
    Environment = "prod"
  }
}

data "aws_vpc" "prod_oranges" {
  id = tolist(data.aws_vpcs.prod_oranges.ids)[0]
}

data "aws_subnet_ids" "prod_oranges_public" {
  vpc_id = data.aws_vpc.prod_oranges.id
    filter {
    name   = "tag:tier"
    values = ["public"]
  }
}

data "aws_subnet" "prod_oranges_public" {
  count =  length(data.aws_subnet_ids.prod_oranges_public.ids)
  id    =  tolist(data.aws_subnet_ids.prod_oranges_public.ids)[count.index]
}


data "aws_subnet_ids" "prod_oranges_private" {
  vpc_id = data.aws_vpc.prod_oranges.id
    filter {
    name   = "tag:tier"
    values = ["private"]
  }
}
data "aws_subnet" "prod_oranges_private" {
  count =  length(data.aws_subnet_ids.prod_oranges_private.ids)
  id    =  tolist(data.aws_subnet_ids.prod_oranges_private.ids)[count.index]
}

resource "aws_autoscaling_group" "oranges" {
  vpc_zone_identifier       = data.aws_subnet.prod_oranges_private.*.id
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = 60
  launch_template {
    id      = aws_launch_template.oranges.id
    version = aws_launch_template.oranges.latest_version
  }

  tag {
    key                 = "update"
    value               = "new"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}

resource "aws_launch_template" "oranges" {
  image_id      = data.aws_ami.oranges.id
  instance_type = "t4g.nano"
  vpc_security_group_ids = [
    aws_security_group.asg_ingress.id,
    aws_security_group.asg_egress.id,
  ]
}



variable "hash" {
  type = string
}
data "aws_caller_identity" "current" {}

data "aws_ami" "oranges" {
  most_recent = true
  owners      = [data.aws_caller_identity.current.account_id]

  filter {
    name   = "tag:hash"
    values = [var.hash]
  }

  filter {
    name   = "name"
    values = ["al2-orange-*"]
  }
}
# references:
# - https://medium.com/@endofcake/using-terraform-for-zero-downtime-updates-of-an-auto-scaling-group-in-aws-60faca582664