resource "aws_iam_role" "app_deploy" {
  name               = "app_deploy"
  path               = "/kca/app/"
  description        = "App Deploy role"
  assume_role_policy = data.aws_iam_policy_document.assumption.json
}
output "deploy_role" {
  value = aws_iam_role.app_deploy.name
}

data "aws_vpcs" "dev" {
  tags = {
    Environment = "dev"
  }
}


resource "aws_iam_role_policy_attachment" "builder" {

  role       = aws_iam_role.builder.name
  policy_arn = aws_iam_policy.builder.arn
}


resource "aws_iam_policy" "builder" {
  name        = "builder"
  path        = "/kca/dev/"
  description = "Policy to allow packer image builds"
  policy      = data.aws_iam_policy_document.builder.json
}
data "aws_iam_policy_document" "builder" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [

      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:subnet/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:Vpc"
      values =   data.aws_vpcs.dev.ids
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
      "iam:PassRole",
      "iam:GetInstanceProfile",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:TerminateInstances",
      "ec2:DescribeVpcs",
    ]
  }
}

resource "aws_iam_role" "builder" {
  name               = "builder"
  path               = "/kca/app/"
  description        = "image builder role"
  assume_role_policy = data.aws_iam_policy_document.assumption.json
}


output "builder_role" {
  value = aws_iam_role.builder.arn
}