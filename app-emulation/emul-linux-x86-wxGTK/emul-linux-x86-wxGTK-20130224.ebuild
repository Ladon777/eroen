# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-baselibs/emul-linux-x86-baselibs-20130224.ebuild,v 1.1 2013/02/25 18:38:17 pacho Exp $

EAPI=5
inherit emul-linux-x86

LICENSE="wxWinLL-3 GPL-2"

KEYWORDS="-* ~amd64"

DEPEND=""
RDEPEND="~app-emulation/emul-linux-x86-baselibs-${PV}
	~app-emulation/emul-linux-x86-gtklibs-${PV}
	|| ( ~app-emulation/emul-linux-x86-xlibs-${PV}
		( 	~media-libs/fontconfig-2.10.2[abi_x86_32]
			~media-libs/freetype-2.4.11[abi_x86_32]
		)
	)
	~x11-libs/wxGTK-2.8.12.1
	"
