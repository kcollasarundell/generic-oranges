resource "aws_iam_role" "tfstate" {
  name               = "tfstate"
  path               = "/kca/core/"
  description        = "Core state role"
  assume_role_policy = data.aws_iam_policy_document.assumption.json
}

resource "aws_iam_role_policy_attachment" "tfstate_attach" {
  role       = aws_iam_role.tfstate.name
  policy_arn = aws_iam_policy.tfstate.arn
}

resource "aws_iam_role" "deploy_core" {
  name               = "deploycore"
  path               = "/kca/core/"
  description        = "Core Deploy role"
  assume_role_policy = data.aws_iam_policy_document.assumption.json
}
output "deploy_role" {
  value = aws_iam_role.deploy_core.arn
}
resource "aws_iam_role_policy_attachment" "deploy_attach" {
  role       = aws_iam_role.deploy_core.name
  policy_arn = aws_iam_policy.deploy.arn
}

resource "aws_iam_policy" "deploy" {
  name        = "deploy_role"
  path        = "/kca/"
  description = "Core deployer policy to manage and restrict this deployer"
  policy      = data.aws_iam_policy_document.deploy.json
}
resource "aws_iam_policy" "tfstate" {
  name        = "tf-state"
  path        = "/kca/core/"
  description = "IAM policy for state access"
  policy      = data.aws_iam_policy_document.tfstate.json
}

# Manual application of state policy

resource "aws_iam_user_policy_attachment" "attach_deployer" {
  user       = "github-admin"
  policy_arn = aws_iam_policy.tfstate.arn
}
resource "aws_iam_user_policy_attachment" "attach_kca" {
  user       = "kca"
  policy_arn = aws_iam_policy.tfstate.arn
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
