A simple Debian repository using S3
===================================

`sthreepo` (read _ess-three-p-oh_) is an extremely simple (and far _FAR_ from
complete) Debian repository manager using [AWS S3](https://aws.amazon.com/s3/)
for storage and [AWS KMS](https://aws.amazon.com/kms/) for signature keys.

* [Signature Keys](#signature-keys)
* [Creating a Repository](#creating-a-repository)
* [Adding Packages](#adding-packages)
* [HTTPS and Authentication](#https-and-authentication)
* [Further Help](#further-help)
* [Copyright Notice](NOTICE.md)
* [License](LICENSE.md)


Signature Keys
--------------

Signature keys are managed in AWS KMS, using the
[`pgpkms`](https://pypi.org/project/pgpkms/) library. Read its documentation
to better understand how to create and manage those keys.


Creating a Repository
---------------------

A repository can be created by simply invoking `sthreepo` with a bucket name,
default index and (optional) origin and label:

```bash
$ python3 -m sthreepo \
  --bucket=my-repo-bucket \
  --default-index=buster:main \
  --origin=Juit \
  --label=Juit
```

Adding Packages
---------------

Once the repository is created (and its state stored in S3) adding packages
should be as easy as calling:

```bash
$ python3 -m sthreepo -b=my-repo-bucket ./my-package.deb
```


HTTPS and Authentication
------------------------

As with any S3-based website, HTTPs and authentication support can be added
using CloudFront.

The [terraform/](https://github.com/juitnow/sthreepo/tree/main/terraform)
directory contains a basic [Terraform](https://www.terraform.io/) setup to
create such an environment.


Further Help
------------

Look at the command line help for more information:

```bash
$ ./bin/sthreepo -h

Usage: ./bin/sthreepo [options] <package.deb>

Options:
  -b, --bucket=<name>   The AWS bucket name of the repository.
  -c, --create-index=distribution:component
                        Create a new index in the repository.
  -d, --default-index=distribution:component
                        Set the default index for the repository.
  -i, --index=distribution:component
                        Use the specified index for the new package.
  -k, --key=<id>        The ID, ARN, or alias of the key to use.
  -l, --label=<label>   Set the label for the repository.
  -n, --name=<name>     The name of the repository (default: "repository").
  -o, --origin=<origin> Set the origin for the repository.
  -v, --verbose         Be more verbose.
      --invalidate-cloudfront=<distribution-id>
                        Invalidate all CloudFront caches for the distribution
                        with the specified ID.

Environment Variables:
  STHREEPO_BUCKET         The AWS bucket name of the repository.
  STHREEPO_KEY            The default ID, ARN or alias of the KMS key to use.
  STHREEPO_CLOUDFRONT_ID  The CloudFront Distribution ID for invalidating caches.
```
