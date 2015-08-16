# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

myPN=PyFFI
myP=${myPN}-${PV}
S="${WORKDIR}"/${myP}

# officially 3.0 - 3.2
PYTHON_COMPAT=(python3_2 python3_3 python3_4)

inherit eutils distutils-r1

DESCRIPTION="Python File Format Interface"
HOMEPAGE="http://${PN}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-py3k/${PV}/${myP}.zip"

LICENSE="BSD havok"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND=""
DEPEND="${LIBDEPEND}
		app-emulation/wine"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
