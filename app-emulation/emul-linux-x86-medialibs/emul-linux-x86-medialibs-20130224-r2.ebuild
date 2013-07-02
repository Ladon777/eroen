# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-medialibs/emul-linux-x86-medialibs-20130224-r2.ebuild,v 1.1 2013/06/27 16:23:32 aballier Exp $

EAPI=5
inherit emul-linux-x86

LICENSE="APL-1.0 GPL-2 BSD BSD-2 public-domain LGPL-2 MPL-1.1 LGPL-2.1 MPEG-4"
KEYWORDS="-* ~amd64"
IUSE="abi_x86_32 filter-libv4l"

DEPEND=""
RDEPEND="~app-emulation/emul-linux-x86-baselibs-${PV}
	~app-emulation/emul-linux-x86-xlibs-${PV}
	~app-emulation/emul-linux-x86-db-${PV}
	!<=app-emulation/emul-linux-x86-sdl-20081109
	!<=app-emulation/emul-linux-x86-soundlibs-20110101
	!filter-libv4l? ( !>=media-libs/libv4l-0.8.9-r1[abi_x86_32] )
	abi_x86_32? (
		>=media-libs/libvpx-1.2.0_pre[abi_x86_32(-)]
		>=media-libs/xvid-1.3.2-r1[abi_x86_32(-)]
		>=media-sound/lame-3.99.5-r1[abi_x86_32(-)]
		>=media-libs/faac-1.28-r4[abi_x86_32(-)]
		>=media-libs/faad2-2.7-r3[abi_x86_32(-)]
		>=media-libs/libtheora-1.1.1-r1[abi_x86_32(-)]
	)
	"
PDEPEND="~app-emulation/emul-linux-x86-soundlibs-${PV}"

src_prepare() {
	# Include all libv4l libs, bug #348277
	ALLOWED="${S}/usr/lib32/libv4l/"
	emul-linux-x86_src_prepare

	# Remove migrated stuff.
	use abi_x86_32 && rm -f $(cat "${FILESDIR}/remove-native")

	# media-libs/libv4l-0.9.5-r1
	if use filter-libv4l; then
		rm usr/lib32/libv4l/ov51{1,8}-decomp || die
		rm usr/lib32/libv4l/v4l1compat.so || die
		rm usr/lib32/libv4l/v4l2convert.so || die
		rm usr/lib32/libv4l{1,2}.so{,.0} || die
		rm usr/lib32/libv4lconvert.so{,.0} || die
		rm usr/lib32/pkgconfig/libv4l{1,2,convert}.pc || die
	fi
}