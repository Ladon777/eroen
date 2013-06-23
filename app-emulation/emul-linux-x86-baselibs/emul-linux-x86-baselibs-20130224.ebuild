# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-baselibs/emul-linux-x86-baselibs-20130224.ebuild,v 1.2 2013/03/16 15:18:18 pacho Exp $

EAPI=5
inherit emul-linux-x86

LICENSE="Artistic GPL-1 GPL-2 GPL-3 BSD BSD-2 BZIP2 AFL-2.1 LGPL-2.1 BSD-4 MIT
	public-domain LGPL-3 LGPL-2 GPL-2-with-exceptions MPL-1.1 OPENLDAP
	Sleepycat UoI-NCSA ZLIB openafs-krb5-a HPND ISC RSA IJG libmng libtiff
	openssl tcp_wrappers_license"

KEYWORDS="-* amd64"
IUSE="filter-bzip2 filter-zlib"

DEPEND=""
RDEPEND="!<app-emulation/emul-linux-x86-medialibs-10.2
	>=sys-libs/glibc-2.15" # bug 340613

PYTHON_UPDATER_IGNORE="1"

src_prepare() {
	export ALLOWED="(${S}/lib32/security/pam_filter/upperLOWER|${S}/etc/env.d|${S}/lib32/security/pam_ldap.so)"

	# app-arch/bzip2-1.0.6-r4
	if use filter-bzip2; then
		rm lib32/libbz2.so{.1,.1.0,.1.0.6} || die
		rm usr/lib32/libbz2.so || die
	fi
	# sys-libs/zlib-1.2.8-r1
	if use filter-zlib; then
		rm lib32/libz.so{.1,.1.2.7} || die
		rm usr/lib32/libz.so || die
		rm usr/lib32/libminizip.so{,.1,.1.0.0} || die
		rm usr/lib32/pkgconfig/{zlib,minizip}.pc || die
	fi

	emul-linux-x86_src_prepare
	rm -rf "${S}/etc/env.d/binutils/" \
			"${S}/usr/i686-pc-linux-gnu/lib" \
			"${S}/usr/lib32/engines/" \
			"${S}/usr/lib32/openldap/" || die

	ln -s ../share/terminfo "${S}/usr/lib32/terminfo" || die
}