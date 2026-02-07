resource "aws_s3_bucket" "markhendrix_dot_com" {
  bucket = "markhendrix.com"
}


resource "aws_s3_bucket_versioning" "markhendrix_dot_com" {
  bucket = aws_s3_bucket.markhendrix_dot_com.id

  versioning_configuration {
    status = "Disabled"
  }

}

resource "aws_s3_bucket_public_access_block" "markhendrix_dot_com" {
  bucket = aws_s3_bucket.markhendrix_dot_com.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.markhendrix_dot_com.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json

  depends_on = [aws_cloudfront_distribution.markhendrix_dot_com]
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.markhendrix_dot_com.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.markhendrix_dot_com.arn]
    }
  }
}
