# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-soundlibs/emul-linux-x86-soundlibs-20130224.ebuild,v 1.1 2013/02/25 18:48:52 pacho Exp $

EAPI=5
inherit emul-linux-x86

LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1 LGPL-2 MIT gsm public-domain"
KEYWORDS="-* ~amd64"
IUSE="alsa fftw-filter"

RDEPEND="~app-emulation/emul-linux-x86-baselibs-${PV}
	~app-emulation/emul-linux-x86-medialibs-${PV}
	!fftw-filter? ( !>=sci-libs/fftw-3.3.3-r1[abi_x86_32] )"

src_prepare() {
	_ALLOWED="${S}/etc/env.d"
	use alsa && _ALLOWED="${_ALLOWED}|${S}/usr/bin/aoss"
	ALLOWED="(${_ALLOWED})"

	emul-linux-x86_src_prepare

	if use alsa; then
		mv -f "${S}"/usr/bin/aoss{,32} || die
	fi

	if use fftw-filter; then
		rm "${S}"/usr/lib32/pkgconfig/fftw3{,f,l}.pc || die "rm 1"
		rm "${S}"/usr/lib32/libfftw3{,f,l}.so{,.3} || die "rm 2"
	fi
}
