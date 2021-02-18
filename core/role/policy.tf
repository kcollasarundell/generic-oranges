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
}

data "aws_iam_policy_document" "iam_control_core" {
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
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicyVersions",
      "iam:UpdatePolicy",
      "iam:*PolicyVersion*",

    ]
  }
}

data "aws_iam_policy_document" "viewer" {

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
    sid    = ""
    effect = "Allow"

    resources = ["*"]
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeClassicLinkInstances",
      "ec2:DescribeClientVpnEndpoints",
      "ec2:DescribeCustomerGateways",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeEgressOnlyInternetGateways",
      "ec2:DescribeFlowLogs",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeManagedPrefixLists",
      "ec2:DescribeMovingAddresses",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaceAttribute",
      "ec2:DescribeNetworkInterfacePermissions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupReferences",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeStaleSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeTrafficMirrorFilters",
      "ec2:DescribeTrafficMirrorSessions",
      "ec2:DescribeTrafficMirrorTargets",
      "ec2:DescribeTransitGatewayRouteTables",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeTransitGatewayVpcAttachments",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcClassicLink",
      "ec2:DescribeVpcClassicLinkDnsSupport",
      "ec2:DescribeVpcEndpointConnectionNotifications",
      "ec2:DescribeVpcEndpointConnections",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServiceConfigurations",
      "ec2:DescribeVpcEndpointServicePermissions",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpnConnections",
      "ec2:DescribeVpnGateways",
      "ec2:DescribePublicIpv4Pools",
      "ec2:GetManagedPrefixListAssociations",
      "ec2:GetManagedPrefixListEntries"
    ]
  }
}

data "aws_iam_policy_document" "deploy_vpc" {
  statement {
    sid    = "Compute"
    effect = "Allow"

    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:vpc/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:natgateway/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:route-table/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:elastic-ip/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:internet-gateway/*",
    ]

    actions = [
      #
      "ec2:DescribeAvailabilityZones",

      "ec2:*Route",

      "ec2:*InternetGateway*",
      "ec2:*NatGateway*",
      "ec2:*RouteTable*",
      "ec2:*Subnet*",
      "ec2:*Tags*",
      "ec2:*Vpc*",
      "ec2:*Interface",

      "ec2:*Addresses*",
      "ec2:*Address",
      "ec2:*Instances*",
      "ec2:*SecurityGroup*",
    ]
  }


  statement {
    sid    = "DNS"
    effect = "Allow"

    resources = [
      "arn:aws:route53:::*/*",
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
    sid       = "Network"
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
