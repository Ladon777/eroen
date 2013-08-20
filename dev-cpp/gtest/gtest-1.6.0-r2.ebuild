# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gtest/gtest-1.6.0-r2.ebuild,v 1.3 2013/08/16 14:44:49 mgorny Exp $

EAPI="5"

# Python is required for tests and some build tasks.
PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils flag-o-matic python-any-r1 autotools-multilib

DESCRIPTION="Google C++ Testing Framework"
HOMEPAGE="http://code.google.com/p/googletest/"
SRC_URI="http://googletest.googlecode.com/files/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples +tr1 static-libs"

DEPEND="app-arch/unzip
	${PYTHON_DEPS}"
RDEPEND=""

PATCHES=(
	"${FILESDIR}/configure-fix-pthread-linking.patch" #371647
)

AUTOTOOLS_AUTORECONF="1"

pkg_setup() {
	python_pkg_setup
	python_set_active_version 2
	if ! use tr1; then
		append-cflags -DGTEST_USE_OWN_TR1_TUPLE=1
		append-cxxflags -DGTEST_USE_OWN_TR1_TUPLE=1
	fi
}

src_prepare() {
	sed -i -e "s|/tmp|${T}|g" test/gtest-filepath_test.cc || die
	sed -i -r \
		-e '/^install-(data|exec)-local:/s|^.*$|&\ndisabled-&|' \
		Makefile.am || die
	autotools-multilib_src_prepare

	multilib_copy_sources
}

src_configure() {
	multilib_parallel_foreach_abi gtest_src_configure
}

src_install() {
	autotools-multilib_src_install
	multilib_for_best_abi gtest-config_install

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins samples/*.{cc,h}
	fi
}

gtest_src_configure() {
	ECONF_SOURCE="${BUILD_DIR}"
	autotools-utils_src_configure
}

gtest-config_install() {
	dobin "${BUILD_DIR}/scripts/gtest-config"
}
