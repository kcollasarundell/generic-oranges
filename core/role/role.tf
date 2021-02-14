resource "aws_iam_policy" "deployer" {
  name        = "Deployer"
  path        = "kca/"
  description = "Core deployer policy to manage and restrict this deployer"
  policy = data.aws_iam_policy_document.deployer.json
}