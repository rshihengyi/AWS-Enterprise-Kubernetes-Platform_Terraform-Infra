
//This might be order of creation issue: need the OIDC token to be created before being able to use CI/CD
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}