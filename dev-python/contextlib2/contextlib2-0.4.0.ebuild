# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT="python2_7"

inherit eutils distutils-r1

DESCRIPTION="Backports and enhancements for the contextlib module"
HOMEPAGE="https://pypi.python.org/pypi/contextlib2"
SRC_URI="https://pypi.python.org/packages/source/c/contextlib2/contextlib2-0.4.0.tar.gz"

LICENSE="PSF-2" # possibly wrong version
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
