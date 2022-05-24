variable "bucket_name" {
  description = "The S3 bucket name for our repository"
  type        = string
}

variable "host_name" {
  description = "The host name to associate with the CloudFront distribution"
  type        = string
}

variable "key_alias" {
  description = "The alias (shorthand name) for the repository signing key"
  type = string
  default = "STHREEPO_KEY"
}

variable "acm_certificate_arn" {
  description = "The ARN of the certificate to use"
  type        = string
}

variable "user" {
  description = "The user name for HTTP authentication"
  type        = string
  default     = null
}

variable "password" {
  description = "The password for HTTP authentication"
  type        = string
  default     = null
}

variable "realm" {
  description = "The realm to use for HTTP authentication"
  type        = string
  default     = "Sthreepo Authentication"
}

# ==============================================================================

output "sthreepo_cname" {
  description = "The CloudFront Distribution host name (for your CNAMEs)"
  value = "${aws_cloudfront_distribution.repository.domain_name}."
}

output "sthreepo_env" {
  description = "Environment variables for the Sthreepo command line"
  value = <<-EOF
    # Environment variables for the Sthreepo command line
    STHREEPO_KEY=${aws_kms_key.repository.id}
    STHREEPO_BUCKET=${aws_s3_bucket.bucket.id}
    STHREEPO_CLOUDFRONT_ID=${aws_cloudfront_distribution.repository.id}
  EOF
}
