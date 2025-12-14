# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "tarot_images_oac" {
  name                              = "${local.name_prefix}-oac"
  description                       = "OAC for Tarot Images"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "tarot_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Tarot Images Distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.tarot_images.bucket_regional_domain_name
    origin_id                = "${local.name_prefix}-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.tarot_images_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.name_prefix}-s3-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "tarot-images-distribution-${var.environment}"
  }
}
