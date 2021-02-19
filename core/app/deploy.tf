
resource "aws_iam_role" "app_deploy" {
  name               = "deploy"
  path               = "/kca/app/"
  description        = "App Deploy role"
  assume_role_policy = data.aws_iam_policy_document.assumption.json
}


data "aws_vpcs" "prod_vpc" {
  tags = {
    Environment = "prod"
  }
}

data "aws_vpc" "prod_vpc" {
  id = tolist(data.aws_vpcs.prod_vpc.ids)[0]
}

output "deploy_role" {
  value = aws_iam_role.app_deploy.name
}

data "aws_iam_policy_document" "assumption" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::234158512104:user/github-admin",
      ]
    }
  }
}


resource "aws_iam_role_policy_attachment" "app_deploy" {
  role       = aws_iam_role.app_deploy.name
  policy_arn = aws_iam_policy.app_deploy.arn
}


resource "aws_iam_policy" "app_deploy" {
  name        = "deploy"
  path        = "/kca/app/"
  description = "Permissions needed by app deployment CD process"
  policy      = data.aws_iam_policy_document.app_deploy.json
}



data "aws_subnet_ids" "prod_oranges_private" {
  vpc_id = data.aws_vpc.prod_vpc.id
  filter {
    name   = "tag:tier"
    values = ["private"]
  }
}

data "aws_subnet" "prod_oranges_private" {
  count = length(data.aws_subnet_ids.prod_oranges_private.ids)
  id    = tolist(data.aws_subnet_ids.prod_oranges_private.ids)[count.index]
}

data "aws_iam_policy_document" "app_deploy" {
  statement {
    sid    = "restrictVPC"
    effect = "Allow"

    resources = data.aws_subnet.prod_oranges_private.*.arn
    actions = [
      "ec2:RunInstances",
    ]
  }

  statement {
    sid    = "allowsecurityGroup"
    effect = "Allow"

    resources = ["*"]

    actions = [
      "ec2:*SecurityGroup*",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:*tags*",
    ]
  }
  statement {
    sid    = ""
    effect = "Allow"

    resources = ["*"]
    actions = [
      # Who am i?
      "sts:GetCallerIdentity",
    ]
  }
  statement {
    sid    = "tfstate"
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      # Policy to allow tf state storage on s3 backend
      "s3:ListBucket",
      "s3:GetBucket",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::*/*",
    ]

    actions = [
      # Policy for terraform state storage on s3 backend
      "s3:GetObject",
      "s3:PutObject",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "iam:CreateServiceLinkedRole",
      "ec2:RunInstances",
      "ec2:*LaunchTemplate*",
      "elasticloadbalancing:*",
      "route53:GetHostedZone",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZones",
      "autoscaling:*",
      "autoscaling-plans:*",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "elasticloadbalancing:Describe*",
      "iam:PassRole",
      "ec2:Describe*",
      "ec2:List*",
    ]
  }
  statement {
    sid    = "DNSwrite"
    effect = "Allow"
    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.generic_oranges.zone_id}",
    ]

    actions = [
      "route53:ChangeResourceRecordSets",
    ]
  }
  statement {
    sid    = "DNSRead"
    effect = "Allow"
    resources = [
      "*",
    ]

    actions = [
      "route53:Get*",
      "route53:List*",
    ]
  }
}


data "aws_route53_zone" "generic_oranges" {
  name = "generic-oranges.dev."
}
