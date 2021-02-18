
resource "aws_lb" "oranges" {
  name               = "oranges"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "oranges" {
  name     = "oranges-worker"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpcs.prod_vpc.ids
}

resource "aws_security_group" "ALB" {
  name        = "ALB"
  description = "Allow http(s) ingress"
  vpc_id      = aws_vpcs.prod_vpc.ids

  ingress {
    description = "https ingress to ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http ingress to ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.asg_ingress
    ]
  }

  tags = {
    Name = "ingress"
  }
}


resource "aws_security_group" "asg_ingress" {
  name        = "asg_ingress"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "inbound http from LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ALB,
    ]
  }

  tags = {
    Name = "worker-ingress"
  }
}
resource "aws_security_group" "asg_ingress" {
  name        = "asg_ingress"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id



  egress {
    from_port   = 53
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "worker-egress"
  }
}