# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libfaketime/libfaketime-0.9.6-r1.ebuild,v 1.1 2014/07/18 16:35:46 radhermit Exp $

EAPI=5

inherit toolchain-funcs multilib-minimal

DESCRIPTION="Report faked system time to programs"
HOMEPAGE="http://www.code-wizards.com/projects/libfaketime/ https://github.com/wolfcw/libfaketime/"
SRC_URI="http://www.code-wizards.com/projects/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	tc-export CC
	multilib_copy_sources
}

multilib_src_compile() {
	emake CC="$(tc-getCC)" LIBDIRNAME="/$(get_libdir)" PREFIX=/usr
}

multilib_src_test() {
	if [[ ${ABI} == ${DEFAULT_ABI} ]]; then
		default_src_test
	else
		einfo "not running tests for ${ABI}"
	fi
}

multilib_src_install() {
	dobin src/faketime
	exeinto /usr/$(get_libdir)
	doexe src/${PN}*.so.*
	dosym ${PN}.so.1 /usr/$(get_libdir)/${PN}.so
	dosym ${PN}MT.so.1 /usr/$(get_libdir)/${PN}MT.so
}

src_install() {
	multilib-minimal_src_install
	doman man/faketime.1
	dodoc NEWS README TODO
}
