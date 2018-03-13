# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit flag-o-matic toolchain-funcs virtualx autotools python-any-r1 git-r3

GTEST_PV=1.8.0

DESCRIPTION="Quite Universal Circuit Simulator in Qt4"
HOMEPAGE="http://qucs.sourceforge.net/"
#SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
SRC_URI="test? ( https://github.com/google/googletest/archive/release-$GTEST_PV.tar.gz -> gtest-$GTEST_PV.tar.gz )"
EGIT_REPO_URI="https://github.com/Qucs/qucs.git"
EGIT_BRANCH="develop"

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="dev-qt/qtcore:4[qt3support]
	dev-qt/qtgui:4[qt3support]
	dev-qt/qtscript:4
	dev-qt/qtsvg:4
	dev-qt/qt3support:4
	x11-libs/libX11:0="
DEPEND="${RDEPEND}
	sci-electronics/adms
	sci-electronics/ASCO
	test? ( ${PYTHON_DEPS} )"

pkg_setup() {
	# avoid python-any-r1_pkg_setup in case tests are disabled and we have no
	# compatible python installed
	:
}

src_unpack() {
	git-r3_src_unpack
	default
}

src_prepare() {
	default

	# oh my, they strip -g out of C*FLAGS
	# note: edit .ac first, then generated files, so that the latter
	# have newer timestamp and not trigger regen
	sed -i \
		-e 's/C.*FLAGS.*sed.*-g.*$/:/' \
		-e 's/C.*FLAGS.*-O0.*$/:/' \
		qucs-core/configure.ac \
		|| die "C*FLAGS sanitization sed failed"

	# let's use our own sandbox-friendly temporary space for tests
	sed -e "s@/tmp/qucstest/@$T/qucstest/@" \
		-i qucs-test/run_equations.py || die

	AT_NO_RECURSIVE=yes eautoreconf
	local d
	for d in qucs-core qucs qucs-doc; do
		pushd $d>/dev/null || die
		AT_NO_RECURSIVE=yes eautoreconf
		popd>/dev/null || die
	done
}

src_configure() {
	local myconf=(
		# enables asserts and debug codepaths
		$(use_enable debug)

		# avoid automagic dep
		# TODO: add support for it
		--disable-mpi

		# TODO: add support for this too
		--disable-doc

		# gtest is strange, see
		# https://github.com/Qucs/qucs/pull/785
		--with-gtest="$WORKDIR"/googletest-release-$GTEST_PV/googletest
	)

	# automagic default on clang++
	tc-export CXX

	econf "${myconf[@]}"
}

src_test() {
	python_setup
	virtx default
}

pkg_postinst() {
	if ! has_version 'sci-electronics/freehdl'; then
		elog "If you would like to be able to run digital simulations, please install:"
		elog "  sci-electronics/freehdl"
	fi
}
