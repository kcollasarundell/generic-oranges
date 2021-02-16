
resource "aws_iam_policy" "view_policy" {
  name        = "view-only-policy"
  path        = "/kca/"
  description = "Visbility into running infrastructure"
  policy      = data.aws_iam_policy_document.viewer.json
}
resource "aws_iam_policy" "iam_control_core" {
  name        = "iam_access"
  path        = "/kca/"
  description = "Control over roles and policies"
  policy      = data.aws_iam_policy_document.iam_control_core.json
}

resource "aws_iam_policy" "core_policy" {
  name        = "core-deployment-policy"
  path        = "/kca/"
  description = "Core deployer policy to manage and restrict this deployer"
  policy      = data.aws_iam_policy_document.deploy_vpc.json
}
resource "aws_iam_policy" "state_policy" {
  name        = "tf-state-store"
  path        = "/kca/core/"
  description = "IAM policy for state access"
  policy      = data.aws_iam_policy_document.tfstate.json
}

# Manual application of state policy
variable "users" {
  type    = list(string)
  default = ["kca", "github-admin"]
}

# This should probably be a group by now
resource "aws_iam_user_policy_attachment" "core_policy" {
  for_each   = toset(var.users)
  user       = each.key
  policy_arn = aws_iam_policy.core_policy.arn
}
resource "aws_iam_user_policy_attachment" "view_policy" {
  for_each   = toset(var.users)
  user       = each.key
  policy_arn = aws_iam_policy.view_policy.arn
}
resource "aws_iam_user_policy_attachment" "iam_control_core" {
  for_each   = toset(var.users)
  user       = each.key
  policy_arn = aws_iam_policy.iam_control_core.arn
}
resource "aws_iam_user_policy_attachment" "state_policy" {
  for_each   = toset(var.users)
  user       = each.key
  policy_arn = aws_iam_policy.state_policy.arn
}

data "aws_iam_policy_document" "assumption" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::234158512104:user/github-admin",
        "arn:aws:iam::234158512104:user/kca",
      ]
    }
  }
}
