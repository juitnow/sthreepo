pydpkg-1.6.0
============

This is a fork of [pydpkg](https://github.com/memory/python-dpkg) version 1.6.0
with its `Dsc` module removed and support for `zstd` archives.

We need this as `pydpkg.Dsc` imports `PGPy` which has some native dependencies
we don't want to actually have (the idea here is to target a small AWS Lambda
function).

Anyhow, for signatures, we use our own `pgpkms` module!

With regards to `zstd`, Ubuntu Focal and Jammy started using this new format,
so if we want to directly import packages from those distributions, we need
to support it!
