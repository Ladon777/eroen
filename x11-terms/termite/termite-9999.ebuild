# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils toolchain-funcs versionator git-2

DESCRIPTION="A keyboard-centric VTE-based terminal"
HOMEPAGE="https://github.com/thestinger/termite"
EGIT_HAS_SUBMODULES=yes
EGIT_REPO_URI="git://github.com/thestinger/termite.git"
#SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE=""

HDEPEND=""
LIBDEPEND=">=x11-libs/gtk+-3.0
	>=x11-libs/vte-0.34[termite-patch]"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

pkg_pretend() {
	if ! version_is_at_least 4.7 $(gcc-version); then
		eerror "${PN} uses -std=c++11 and requires a version"
		eerror "of gcc newer than 4.7.0"
	fi
}

src_prepare() {
	sed -i '/PREFIX/s:/usr/local:/usr:' Makefile
	sed -i 's/-O3//g' Makefile
	sed -i '/LDFLAGS/s/-s//' Makefile
}

src_install() {
	default
	dodoc config
}

pkg_postinst() {
	elog
	elog "Termite looks for a config file ~/.config/termite/config"
	elog "An example config can be found in ${ROOT}usr/share/doc/${PF}/"
}
