# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.3.1.ebuild,v 1.1 2013/06/01 06:46:33 ssuominen Exp $

EAPI=5
inherit autotools-multilib

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND="
	abi_x86_32? ( || (
			app-emulation/emul-linux-x86-soundlibs[filter-${PN}]
			!<=app-emulation/emul-linux-x86-soundlibs-20130224 ) )"

AUTOTOOLS_PRUNE_LIBTOOL_FILES=all
DOCS=( AUTHORS CHANGES )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/ogg/config_types.h
)

src_configure() {
	local myeconfargs=(
		--htmldir=/usr/share/doc/${PF}/html
		)
	autotools-multilib_src_configure
}
