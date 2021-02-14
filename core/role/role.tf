resource "aws_iam_policy" "deployer" {
  name        = "Deployer"
  path        = "/kca/"
  description = "Core deployer policy to manage and restrict this deployer"
  policy = data.aws_iam_policy_document.deployer.json
}

data "aws_iam_policy_document" "deployer" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
        "sts:AssumeRole",
        ]
            principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::234158512104:user/github-admin", "arn:aws:iam::234158512104:user/kca" ]
    }
  }
}

resource "aws_iam_role" "deploy-core" {
    name = "deploy-core"
    path = "/kca/core/"
    description = "Core Deploy role"
    assume_role_policy = ""
}