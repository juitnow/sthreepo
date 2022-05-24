#!/bin/bash

set -e

test -f "$(dirname ${0})/.env" && {
  set -a
  source "$(dirname ${0})/.env"
  set +a
}

rm -rf "./dist"

python3 setup.py sdist

VERSION=$(grep -m1 -Po '(?<=^Version:\s).*$' ./sthreepo.egg-info/PKG-INFO)
: "${VERSION:?Version could not be determined}"

umask 022

mkdir -p "./dist/deb/usr/lib/python3/dist-packages"

tar --extract \
	--strip-components=1 \
	--directory="./dist/deb/usr/lib/python3/dist-packages" \
	--file="./dist/sthreepo-${VERSION}.tar.gz" \
	"sthreepo-${VERSION}/sthreepo" \
	"sthreepo-${VERSION}/sthreepo.egg-info"

mv --force \
	"./dist/deb/usr/lib/python3/dist-packages/sthreepo.egg-info" \
	"./dist/deb/usr/lib/python3/dist-packages/sthreepo-${VERSION}.egg-info"

mkdir -p "./dist/deb/DEBIAN"
mkdir -p "./dist/deb/usr/bin"
mkdir -p "./dist/deb/etc/default"
mkdir -p "./dist/deb/usr/share/doc/python3-sthreepo"

install --mode=755 ./bin/sthreepo "./dist/deb/usr/bin/sthreepo"
install --mode=644 README.md "./dist/deb/usr/share/doc/python3-sthreepo/README.md"
install --mode=644 NOTICE.md "./dist/deb/usr/share/doc/python3-sthreepo/NOTICE.md"
install --mode=644 LICENSE.md "./dist/deb/usr/share/doc/python3-sthreepo/LICENSE.md"

cat >> "./dist/deb/etc/default/sthreepo" <<-EOF
	# STHREEPO_BUCKET the bucket name where the repository is stored
	#STHREEPO_BUCKET=my-repo-bucket
	# STHREEPO_KEY the ID, ARN or alias of the KMS key used to sign the repository
	#STHREEPO_KEY=alias/MyPgpKey
	EOF

cat >> "./dist/deb/DEBIAN/control" <<-EOF
	Package: python3-sthreepo
	Architecture: all
	Priority: optional
	Section: python
	Version: ${VERSION}-1
	Maintainer: Juit Developers <developers@juit.com>
	Homepage: https://github.com/juitnow/STHREEPO_KEY
	Depends: python3:any, python3-botocore (>= 1.23), python3-arpy (>= 1.1), python3-pgpkms (>= 1.0.7)
	Description: Use AWS KMS keys to generate GnuPG/OpenPGP compatible signatures
	EOF

cat >> "./dist/deb/DEBIAN/conffiles" <<-EOF
	/etc/default/sthreepo
	EOF

dpkg-deb --root-owner-group -b "./dist/deb" "./python3-sthreepo_${VERSION}-1_all.deb"

if test "${1}" = "upload"; then
	twine upload "./dist/sthreepo-${VERSION}.tar.gz"
fi
