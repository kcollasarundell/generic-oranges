
resource "aws_lb" "oranges" {
  name               = "oranges"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  subnets            = data.aws_subnet.prod_oranges_public.*.id
  ip_address_type = "dualstack"
  enable_deletion_protection = false
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "oranges" {
  name     = "oranges-worker"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.prod_oranges.id
}

resource "aws_lb_listener" "oranges" {
  load_balancer_arn = aws_lb.oranges.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.generic_oranges.certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oranges.arn
  }
}

resource "aws_security_group" "ALB" {
  name        = "ALB"
  description = "Allow http(s) ingress"
  vpc_id      = data.aws_vpc.prod_oranges.id

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
  vpc_id      = data.aws_vpc.prod_oranges.id

  ingress {
    description = "inbound http from LB"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ALB.id,
    ]
  }

  tags = {
    Name = "worker-ingress"
  }
}
resource "aws_security_group" "asg_egress" {
  name        = "asg_egress"
  description = "Allow outbound traffic"
  vpc_id      = data.aws_vpc.prod_oranges.id

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "worker-egress"
  }
}

data "aws_route53_zone" "oranges" {
  name = "generic-oranges.dev."
}

resource "aws_route53_record" "all" {
  zone_id = data.aws_route53_zone.oranges.zone_id
  name    = "*.generic-oranges.dev."
  type    = "A"

  alias {
    name                   = aws_lb.oranges.dns_name
    zone_id                = aws_lb.oranges.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.oranges.zone_id
  name    = "generic-oranges.dev."
  type    = "A"

  alias {
    name                   = aws_lb.oranges.dns_name
    zone_id                = aws_lb.oranges.zone_id
    evaluate_target_health = false
  }
}


resource "aws_acm_certificate" "generic_oranges" {
  domain_name = "generic-oranges.dev"
  subject_alternative_names = [
    "www.generic-oranges.dev",
    "*.generic-oranges.dev"
  ]
  validation_method = "DNS"
}


resource "aws_route53_record" "generic_oranges" {
  for_each = {
    for dvo in aws_acm_certificate.generic_oranges.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.oranges.zone_id
}

resource "aws_acm_certificate_validation" "generic_oranges" {
  certificate_arn         = aws_acm_certificate.generic_oranges.arn
  validation_record_fqdns = [for record in aws_route53_record.generic_oranges : record.fqdn]
}
