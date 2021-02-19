
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
  count = length(data.aws_vpcs.prod_vpc.ids)
  id    = tolist(data.aws_vpcs.prod_vpc.ids)[count.index]
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

data "aws_iam_policy_document" "app_deploy" {
  statement {
    sid    = "restrictVPC"
    effect = "Allow"

    resources = [
      "arn:aws:ec2:*::subnet/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:Vpc"
      values   = data.aws_vpc.prod_vpc[*].arn
    }

    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
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
      "elasticloadbalancing:*",
      "route53:GetHostedZone",
      "route53:GetHostedZoneCount",
      "route53:ListHostedZones",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:PutScalingPolicy",
      "autoscaling:DescribePolicies",
      "autoscaling:DeletePolicy",
      "autoscaling-plans:*",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "elasticloadbalancing:Describe*",
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
