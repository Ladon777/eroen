# By eroen, 2013 - 2015
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

PYTHON_COMPAT=(python2_7)
inherit eutils python-single-r1 cmake-utils

DESCRIPTION="LOLCODE interpreter written in C"
HOMEPAGE="http://lolcode.org/"
LICENSE="GPL-3+"
SLOT="0"
IUSE="test memtest"

if [[ ${PV} == 9999 ]]; then
	inherit git-2
	EGIT_REPO_URI=https://github.com/justinmeza/lci.git
else
	SRC_URI="https://github.com/justinmeza/${PN}/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

HDEPEND="test? (
		virtual/python-argparse[${PYTHON_USEDEP}]
		memtest? ( dev-util/valgrind ) )"
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

src_prepare() {
	epatch_user
	python_fix_shebang test/testDriver.py
}

src_configure() {
	mycmakeargs=($(cmake-utils_use memtest PERFORM_MEM_TESTS:BOOL))
	cmake-utils_src_configure
}
