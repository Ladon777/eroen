# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit autotools eutils multiprocessing toolchain-funcs versionator games subversion

DESCRIPTION="City/country simulation game for X and opengl"
HOMEPAGE="https://fedorahosted.org/LinCity-NG/"
#SRC_URI="mirror://berlios/${PN}/${P/_beta/.beta}.tar.bz2"
ESVN_REPO_URI="svn://svn.berlios.de/lincity-ng/trunk"

LICENSE="GPL-2+ BitstreamVera"
SLOT="0"
KEYWORDS=""
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
	epatch "${FILESDIR}"/${PN}-2.9_beta-build.patch

	# No CREDITS file in svn
	sed -e 's/CREDITS//g' -i Jamfile

	# Wacky autogen.sh is wacky.
	eaclocal -I mk/autoconf
	eautoheader
	# autotools.eclass eats the output and adds some lines of its own.
	eautoconf --trace=AC_SUBST
	tail -n +4 "${T}"/autoconf.out \
		| sed -e 's/configure.ac:[0-9]*:AC_SUBST:\([^:]*\).*/\1 ?= "@\1@" ;/g' \
		| sed -e 's/.*BACKSLASH.*//' \
		> Jamconfig.in
	echo 'INSTALL ?= "@INSTALL@" ;' >> Jamconfig.in
	echo 'JAMCONFIG_READ = yes ;' >> Jamconfig.in
	eautoconf
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

pkg_preinst() {
	subversion_pkg_preinst
	games_pkg_preinst
}
