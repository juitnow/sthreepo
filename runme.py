import logging
import sys

root = logging.getLogger()
# root.setLevel(logging.DEBUG)

logging.getLogger('sthreepo').setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
# handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s [%(levelname)-5s] %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)


from html import escape
from sthreepo import Package, Repository, process, prettify

import json
import gzip
import lzma
import os

from io import StringIO
from hashlib import md5, sha1, sha256

from pgpkms import KmsPgpKey
from botocore import session as aws
from datetime import datetime
import zoneinfo
from email import utils

from pprint import pp

repository = Repository()

repository.add_index('focal:stable')
repository.add_index('focal:main')
repository.add_index('jammy:main')

repository.add_package(Package('./bash_5.1-6ubuntu1_amd64.deb'), 'focal:main')
repository.add_package(Package('./minimal-os_1.0.4_all.deb'), 'focal:main')
repository.add_package(Package('../ops-docker-odoo/deb/odoo.deb'), 'focal:main')
repository.add_package(Package('../pgp-kms/python3-pgpkms_1.0.1-1_all.deb'), 'focal:main')
repository.add_package(Package('../pgp-kms/python3-pgpkms_1.0.2-1_all.deb'), 'focal:main')
repository.add_package(Package('../pgp-kms/python3-pgpkms_1.0.3-1_all.deb'), 'focal:main')
repository.add_package(Package('../pgp-kms/python3-pgpkms_1.0.4-1_all.deb'), 'focal:main')
repository.add_package(Package('../session-manager-plugin.deb'), 'focal:main')
repository.add_package(Package('../wkhtmltox_0.12.5-1.focal_arm64.deb'), 'focal:main')
repository.add_package(Package('../wkhtmltox_0.12.5-1.jammy_arm64.deb'), 'jammy:main')

session = aws.get_session()
kms_client = session.create_client('kms')
s3_client = session.create_client('s3')

key = KmsPgpKey('alias/PGP_KEY', kms_client = kms_client)

files = process(repository, 'alias/PGP_KEY', 'pier.test', kms_client=kms_client)

# for name, (content, content_type) in files.items():
#   print('Uploading %s' % (name))
#   s3_client.put_object(
#     Bucket = 'pier.test',
#     Key = 'repository/%s' % (name),
#     ContentType = content_type,
#     Body = content,
#   )

prettify('pier.test', 'repository')
# pp(list)

# state = json.dumps(repository)
# repo2 = Repository(json.loads(state))

# with open('1.json', 'w') as f:
#   f.write(json.dumps(repository, indent=2))

# with open('2.json', 'w') as f:
#   f.write(json.dumps(repo2, indent=2))
