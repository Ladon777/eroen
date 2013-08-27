# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT="python2_7"

inherit eutils distutils-r1

DESCRIPTION="converts Python byte-code back into equivalent Python source"
HOMEPAGE="https://github.com/gstarnberger/uncompyle"
SRC_URI="https://github.com/gstarnberger/uncompyle/archive/v0.0.2.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
