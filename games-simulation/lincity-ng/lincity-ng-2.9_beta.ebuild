# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils multiprocessing toolchain-funcs versionator games

DESCRIPTION="City/country simulation game for X and opengl"
HOMEPAGE="https://fedorahosted.org/LinCity-NG/"
SRC_URI="mirror://berlios/${PN}/${P/_beta/.beta}.tar.bz2"

LICENSE="GPL-2+ BitstreamVera"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="virtual/opengl
	>=sys-libs/zlib-1.0
	>=dev-libs/libxml2-2.6.11
	>=media-libs/libsdl-1.2.14[joystick,opengl,sound,video]
	>=media-libs/sdl-mixer-1.2.4[vorbis]
	>=media-libs/sdl-image-1.2.3[png]
	>=media-libs/sdl-ttf-2.0.8
	>=media-libs/sdl-gfx-2.0.13
	>=dev-games/physfs-1.0.0"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=dev-util/ftjam-2.5"

S="${WORKDIR}"/${P/_beta/.beta}

pkg_pretend() {
	# Needs gcc/g++ 3.2 or later according to configure.ac/docs.
	if ! version_is_at_least 3.2 $(gcc-version); then
		eerror
		eerror "sys-devel/gcc-3.2 or later is required to build ${P}"
		eerror "Please select a more recent compiler using gcc-config"
		eerror
		die
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.patch
}

src_compile() {
	jam -q -dx -j $(makeopts_jobs) || die "jam failed"
}

src_install() {
	jam -sDESTDIR="${D}" \
		 -sappdocdir="/usr/share/doc/${PF}" \
		 -sapplicationsdir="/usr/share/applications" \
		 -spixmapsdir="/usr/share/pixmaps" \
		 install \
		 || die "jam install failed"
	rm -f "${D%/}"/usr/share/doc/${PF}/COPYING*
	prepgamesdirs
}
