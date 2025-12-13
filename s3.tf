# S3 Bucket for Tarot Images
resource "aws_s3_bucket" "tarot_images" {
  bucket = "${local.name_prefix}-images"
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "tarot_images" {
  bucket = aws_s3_bucket.tarot_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for CloudFront Access
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
