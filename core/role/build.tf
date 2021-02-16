resource "aws_iam_role" "app_deploy" {
  name               = "app_deploy"
  path               = "/kca/app/"
  description        = "App Deploy role"
  assume_role_policy = data.aws_iam_policy_document.assumption.json
}
output "deploy_role" {
  value = aws_iam_role.app_deploy.arn
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

output "app_deploy" {
  value = aws_iam_role.app_deploy.arn
}