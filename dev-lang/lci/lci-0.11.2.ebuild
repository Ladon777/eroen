# By eroen <eroen-overlay@occam.eroen.eu>, 2013 - 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6

PYTHON_COMPAT=(python2_7)
inherit python-any-r1 cmake-utils

DESCRIPTION="LOLCODE interpreter written in C"
HOMEPAGE="http://lolcode.org https://github.com/justinmeza/lci"
LICENSE="GPL-3+"
SLOT="0"
IUSE="doc memtest test"

if [[ ${PV} == 9999 ]]; then
	inherit git-3
	EGIT_REPO_URI=https://github.com/justinmeza/lci.git
else
	SRC_URI="https://github.com/justinmeza/${PN}/archive/v${PV}.tar.gz -> $P.tar.gz"
	KEYWORDS="~amd64"
fi

RDEPEND=""
DEPEND="
	doc? ( app-doc/doxygen )
	test? (
		${PYTHON_DEPS}
		memtest? ( dev-util/valgrind ) )"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
	use test && python_fix_shebang test/testDriver.py

	# broken for out-of-source builds
	sed -e '/PROJECT_LOGO/d' \
		-i Doxyfile || die
}

src_configure() {
	local mycmakeargs=(
		"-DPERFORM_MEM_TESTS:BOOL=$(usex test "$(usex memtest)")"
		)
	einfo $mymakeargs
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	use doc && cmake-utils_src_compile docs
}

src_install() {
	cmake-utils_src_install
	dodoc -r "$BUILD_DIR/html"
}
