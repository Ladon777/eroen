# By eroen <eroen-overlay@occam.eroen.eu>, 2013 - 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

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
