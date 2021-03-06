# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libfaketime/libfaketime-0.9.5.ebuild,v 1.1 2014/03/06 04:16:56 radhermit Exp $

EAPI=5

inherit eutils toolchain-funcs multilib-minimal

DESCRIPTION="Report faked system time to programs"
HOMEPAGE="http://www.code-wizards.com/projects/libfaketime/ https://github.com/wolfcw/libfaketime/"
SRC_URI="http://www.code-wizards.com/projects/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	epatch "${FILESDIR}"/0001-Fake-__clock_gettime-and-similar-calls-using-__.-cal.patch
	epatch "${FILESDIR}"/0002-Finish-safe-faking-of-internal-calls.patch
	tc-export CC
	multilib_copy_sources
}

multilib_src_test() {
	if [[ ${ABI} == ${DEFAULT_ABI} ]]; then
		default_src_test
	else
		einfo "not running tests for ${ABI}"
		echo ${DEFAULT_ABI}
	fi
}

multilib_src_install() {
	dobin src/faketime
	exeinto /usr/$(get_libdir)/faketime
	doexe src/${PN}*.so.*
	dosym ${PN}.so.1 /usr/$(get_libdir)/faketime/${PN}.so
	dosym ${PN}MT.so.1 /usr/$(get_libdir)/faketime/${PN}MT.so
}

src_install() {
	multilib-minimal_src_install
	doman man/faketime.1
	dodoc NEWS README TODO
}
