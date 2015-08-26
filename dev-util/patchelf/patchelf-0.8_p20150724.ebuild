# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

AUTOTOOLS_AUTORECONF=true

inherit autotools-utils

DESCRIPTION="Small utility to modify the dynamic linker and RPATH of ELF executables"
HOMEPAGE="http://nixos.org/patchelf.html https://github.com/NixOS/patchelf"
#SRC_URI="http://releases.nixos.org/${PN}/${P}/${P}.tar.bz2"
MY_COMMIT=b202ad239ed815fbc59dd0a5cb2def5991116c42
SRC_URI="https://github.com/NixOS/patchelf/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
S=$WORKDIR/${PN}-$MY_COMMIT

SLOT="prerelease"
KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"
LICENSE="GPL-3"
IUSE=""

AUTOTOOLS_IN_SOURCE_BUILD=1

src_prepare() {
	rm -f src/elf.h || die
	sed -e 's:-Werror::g' -i configure.ac || die
	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=( --docdir="${EPREFIX}"/usr/share/doc/${PF} )
	autotools-utils_src_configure
}

src_test() {
	autotools-utils_src_test -j1
}

src_install() {
	autotools-utils_src_install
	mv "${ED%/}"/usr/bin/patchelf{,-${SLOT}} || die
	mv "${ED%/}"/usr/share/man/man1/patchelf{,-${SLOT}}.1 || die
}
