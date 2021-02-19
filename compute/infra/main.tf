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
  vpc_id = data.aws_vpcs.prod_oranges.ids
}

data "aws_subnet" "prod_oranges_public" {
  for_each = data.aws_subnet_ids.prod_oranges.ids
  id       = each.value
  tags = {
    tier = "public"
  }
}

data "aws_subnet" "prod_oranges_private" {
  for_each = data.aws_subnet_ids.prod_oranges.ids
  id       = each.value
  tags = {
    tier = "private"
  }
}

data "aws_subnet_ids" "prod_oranges" {
  vpc_id = data.aws_vpcs.prod_oranges.ids
}


resource "aws_autoscaling_group" "oranges" {
  vpc_zone_identifier       = aws_subnet.prod_oranges_private.*.id
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
    triggers = ["tag", "launch_template"]
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

data "aws_ami" "oranges" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "hash"
    values = [var.hash]
  }

  filter {
    name   = "name"
    values = ["al2-orange-*"]
  }
}
# references:
# - https://medium.com/@endofcake/using-terraform-for-zero-downtime-updates-of-an-auto-scaling-group-in-aws-60faca582664