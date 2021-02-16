data "aws_caller_identity" "current" {}
# This permission set is overly broad and should be broken up.
data "aws_iam_policy_document" "tfstate" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::*",
    ]

    actions = [
      # Policy to allow tf state storage on s3 backend
      "s3:ListBucket",
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
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
     
      
      # User perms
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:GetUser",
      "iam:ListAttachedUserPolicies",
      "iam:ListUsers",

      #Roles
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:PutRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateAssumeRolePolicy",


      # Policy Attachment
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicyVersions",
      "iam:UpdatePolicy",

    ]
  }
}



data "aws_iam_policy_document" "deploy" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:vpc/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:natgateway/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:route-table/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:elastic-ip/*",
    ]

    actions = [
      "ec2:AttachInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRouteTable",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteTags",
      "ec2:DescribeVpcClassicLink",
      "ec2:DescribeAccountAttributes",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:route53:::*/*",
      "arn:aws:route53:::healthcheck/*",
    ]

    actions = [
      "route53:ChangeTagsForResource",
      "route53:CreateHostedZone",
      "route53:DeleteHostedZone",
      "route53:GetAccountLimit",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListHostedZonesByVPC",
      "route53:UpdateHostedZoneComment",
      "route53:ListTagsForResource"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeNatGateways",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
    ]
  }
}
