# ==============================================================================
# A CloudFront Function processing the request.
# - Serve our "index.html" for all directory requests (ending with "/")
# - Perform basic authentication if credentials are provided
#
locals {
  # The "credentials" local variable is either an empty string, or the
  # base64-encoded concatenation of "user:password"
  credentials = var.user == null ? "" : base64encode(format("%s:%s", var.user, var.password))
}

resource "aws_cloudfront_function" "function" {
  name    = "sthreepo-request"
  runtime = "cloudfront-js-1.0"
  comment = "STHREEPO: Process requests"
  publish = true
  code    = <<-EOF
    // Our credentials, either an empty string or "user:password" base64-encoded
    var credentials = '${local.credentials}';

    // The 401 response to return in case of missing or invalid authorization
    var unauthorized = {
      statusCode: 401,
      statusDescription: 'Unauthorized',
      headers: {
          'www-authenticate': { value: 'Basic realm="${var.realm}", charset="UTF-8"' },
      },
    };

    // Process requests, serving to the index file (in case of directories) and
    // performing "basic" authentication if credentials are specified
    function handler(event) {
      var request = event.request;

      // In all cases, requests ending with ".../" get served by "index.html"
      if (request.uri.endsWith('/')) request.uri += 'index.html';

      // If we don't have credentials, return the request
      if (! credentials) return request;

      // Check if we have an "Authorization" header
      if (! request.headers['authorization']) return unauthorized

      // Check that the "Authorization" header specifies "basic" authorization
      var authorization = request.headers['authorization'].value.trim()
      if (! authorization.toLowerCase().startsWith('basic ')) return unauthorized

      // The base64-encoded "user:password" string follows "basic"
      if (authorization.substr(6).trim() != credentials) return unauthorized

      // Authorization matches
      return request
    }
  EOF
}

# ==============================================================================
# The Origin Access Identity that CloudFront will use to contact S3
#
resource "aws_cloudfront_origin_access_identity" "identity" {
  comment = "STHREEPO: Origin Access Identity"
}

# ==============================================================================
# An S3 bucket policy granting CloudFront read-only access to our S3 bucket
#
data "aws_iam_policy_document" "bucket_policy" {
  # Give access to CloudFront to read objects
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.identity.iam_arn]
    }
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    sid       = "CloudFront-GetObject"
  }

  # Give access to ClouFront to list the bucket
  statement {
    actions = ["s3:ListBucket"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.identity.iam_arn]
    }
    resources = ["arn:aws:s3:::${var.bucket_name}"]
    sid       = "CloudFront-ListBucket"
  }
}

# ==============================================================================
# The S3 bucket for our repository, followed by its bucket policy and ACL
#
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

# ==============================================================================
# The CloudFront distribution backed by our S3 bucket for the repository
#
resource "aws_cloudfront_distribution" "repository" {
  enabled             = true
  wait_for_deployment = false

  aliases             = [var.host_name]
  default_root_object = "index.html"
  is_ipv6_enabled     = true

  # Basic S3 origin for this bucket
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3-${aws_s3_bucket.bucket.id}"
    origin_path = "/repository"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "s3-${aws_s3_bucket.bucket.id}"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # CloudFront Function association
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.function.arn
    }
  }

  # No restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method      = "sni-only"
  }
}

# ==============================================================================
# The CloudFront distribution backed by our S3 bucket for the repository
#
resource "aws_kms_key" "repository" {
  description              = "STHREEPO: Repository Signing Key"
  customer_master_key_spec = "RSA_4096"
  key_usage                = "SIGN_VERIFY"
}

resource "aws_kms_alias" "repository" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.repository.key_id
}
