
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

data "aws_iam_policy_document" "deployer" {
    statement {
    sid    = "restrictVPC"
    effect = "Allow"

    resources = [
      "arn:aws:ec2:*::subnet/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:Vpc"
      values   = data.aws_vpc.prod_vpc[*].arn
    }

    actions = [
      "ec2:RunInstances",
    ]
  }
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
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
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"
    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.generic_oranges.zone_id}",
    ]

    actions = [
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
    ]
  }
}


data "aws_route53_zone" "generic_oranges" {
  name = "generic-oranges.dev."
}
