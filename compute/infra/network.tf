
resource "aws_lb" "oranges" {
  name               = "oranges"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  subnets            = aws_subnet.prod_oranges_public.*.id

  enable_deletion_protection = false
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "oranges" {
  name     = "oranges-worker"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpcs.prod_oranges.ids
}

resource "aws_lb_listener" "oranges" {
  load_balancer_arn = aws_lb.oranges.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oranges.arn
  }
}

resource "aws_security_group" "ALB" {
  name        = "ALB"
  description = "Allow http(s) ingress"
  vpc_id      = data.aws_vpcs.prod_oranges.ids

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
resource "aws_security_group" "asg_egress" {
  name        = "asg_egress"
  description = "Allow outbound traffic"
  vpc_id      = data.aws_vpcs.prod_oranges.ids

  egress {
    from_port   = 53
    protocol    = "tcp"
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

data "aws_route53_zone" "oranges" {
  name  = "generic-oranges.dev."
}

resource "aws_route53_record" "all" {
  zone_id = aws_route53_zone.oranges.zone_id
  name    = "*.generic-oranges.dev."
  type    = "A"
  ttl     = "300"

  alias {
    name                   = aws_lb.oranges.dns_name
    zone_id                = aws_lb.oranges.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.oranges.zone_id
  name    = "generic-oranges.dev."
  type    = "A"
  ttl     = "300"

  alias {
    name                   = aws_lb.oranges.dns_name
    zone_id                = aws_lb.oranges.zone_id
    evaluate_target_health = false
  }
}