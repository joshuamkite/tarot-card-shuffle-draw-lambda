resource "aws_s3_bucket" "tarot_images" {
  bucket = "${local.name_prefix}-images-${local.account_id}"
}

resource "aws_s3_bucket_public_access_block" "tarot_images" {
  bucket = aws_s3_bucket.tarot_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tarot_images_policy" {
  bucket = aws_s3_bucket.tarot_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.tarot_images.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.tarot_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.tarot_images]
}

resource "aws_s3_object" "card" {
  for_each = toset(fileset("${path.module}/../assets/images", "*"))

  bucket = aws_s3_bucket.tarot_images.id
  key    = "images/${each.value}"
  source = "${path.module}/../assets/images/${each.value}"
  etag   = filemd5("${path.module}/../assets/images/${each.value}")
}
