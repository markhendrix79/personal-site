# IAM Identity Provider for Github OIDC

resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Assume Role Policy
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:markhendrix79/personal-site:ref:refs/heads/main"]
    }
  }
}

# Permission Policy - S3 only
data "aws_iam_policy_document" "update_personal_site" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [aws_s3_bucket.markhendrix_dot_com.arn, "${aws_s3_bucket.markhendrix_dot_com.arn}/*"]
  }

  statement {
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.markhendrix_dot_com.arn]
  }
}

resource "aws_iam_policy" "update_personal_site" {
  name        = "update-personal-site"
  description = "Allow github actions access to update personal website."
  policy      = data.aws_iam_policy_document.update_personal_site.json
}

# Role
resource "aws_iam_role" "github_actions" {
  name               = "personal-site-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# Attach s3 policy to role
resource "aws_iam_role_policy_attachment" "update_personal_site" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.update_personal_site.arn
}
