################################################################################
# IAM Policy - Manage Terraform State
################################################################################

data "aws_iam_policy_document" "read_write_terraform_state" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::effectful-terraform-state"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::effectful-terraform-state/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/effectful-terraform-state"]
  }
}

resource "aws_iam_policy" "read_write_terraform_state" {
  name        = "read-write-terraform-state"
  description = "Grant access to S3 bucket and DynamoDB table used to manage Terraform state"
  policy      = data.aws_iam_policy_document.read_write_terraform_state.json
}

data "aws_iam_policy_document" "terraform_enforcement" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListRolePolicies",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_enforcement" {
  name        = "terraform-enforcement"
  description = "Grant the least privileged access required for Terraform in AWS"
  policy      = data.aws_iam_policy_document.terraform_enforcement.json
}

################################################################################
# IAM Role - GitHub Actions OIDC
################################################################################

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions" {
  version = "2012-10-17"

  statement {
    sid = "GithubActionsAssumeRole"

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:Effect-TS/infra:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubAction-AssumeRoleWithAction"
  assume_role_policy = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.read_write_terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "terraform_enforcement" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_enforcement.arn
}
