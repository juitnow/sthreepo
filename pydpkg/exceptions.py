""" pydpkg.exceptions: what it says on the tin """


class DpkgError(Exception):
    """Base error class for Dpkg errors"""


class DpkgVersionError(DpkgError):
    """Corrupt or unparseable version string"""


class DpkgMissingControlFile(DpkgError):
    """No control file found in control.tar.gz/xz"""


class DpkgMissingControlGzipFile(DpkgError):
    """No control.tar.gz/xz file found in dpkg file"""


class DpkgMissingRequiredHeaderError(DpkgError):
    """Corrupt package missing a required header"""
