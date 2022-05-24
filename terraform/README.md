Basic Terraform setup for Sthreepo
==================================

Setup `sthreepo` using CloudFront to provide HTTPs and basic authentication
support to your repository.

Simply create a `terraform.tfvars` file with the basic variables to make this
work:

```
# The bucket name for your repository
bucket_name         = "my-sthreepo-repository"
# The host name you want to associate with the repository
host_name           = "repository.domain.dom"
# The ACM certificate for your repository (must be in "us-east-1")
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"

# (Optional) The user name and password basic authentication
#user                = "juit"
#password            = "juitakafrostyavocado"
```

Your mileage might vary, look at the [Terraform](https://www.terraform.io/)
documentation for how to get started.
