# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pqiv/pqiv-2.0.ebuild,v 1.1 2013/09/08 05:09:06 radhermit Exp $

EAPI=5
inherit linux-info toolchain-funcs eutils

DESCRIPTION="Modern rewrite of Quick Image Viewer"
HOMEPAGE="http://github.com/phillipberndt/pqiv http://www.pberndt.com/Programme/Linux/pqiv/"
SRC_URI="https://github.com/phillipberndt/pqiv/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="kernel_linux"

RDEPEND="dev-libs/glib:2
	x11-libs/cairo
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

pkg_setup() {
	if use kernel_linux; then
		CONFIG_CHECK="~INOTIFY_USER"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-ldflags.patch
	sed -e '/^PQIV_WARNING_FLAGS/s/-Werror//' \
		-i "${S}/Makefile" || die
}

src_configure() {
	./configure --prefix=/usr --destdir="${D}" || die
}

src_compile() {
	tc-export CC
	emake CFLAGS="${CFLAGS}"
}

src_install() {
	default
	dodoc README.markdown
}