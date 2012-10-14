# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit games versionator scons-utils multilib

DF_PN="df"
DF_PV="$(replace_all_version_separators '_')"
DF_P="${DF_PN}_${DF_PV}"

DESCRIPTION="General purpose library used for games-simulation/dwarffortress"
HOMEPAGE="https://github.com/Baughn/Dwarf-Fortress--libgraphics-"
SRC_URI="http://www.bay12games.com/dwarves/${DF_P}_linux.tar.bz2"

LICENSE="DwarfFortress as-is LGPL-2.1 BSD fmod MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND_SCONSCRIPT="virtual/pkgconfig
	media-libs/sdl-image
	sys-libs/zlib
	media-libs/sdl-ttf
	media-libs/libsndfile
	x11-libs/gtk+
	media-libs/openal
	media-libs/libsndfile
	media-libs/libsdl
	media-libs/glu
	media-libs/glew
	"

DEPEND_INCLUDE="media-libs/fmod
	media-libs/libsdl
	media-libs/libsndfile
	media-libs/openal
	media-libs/sdl-ttf
	sys-libs/zlib
	"

COMMON_DEPEND="!games-simulation/dwarffortress[libgraphics]
	app-emulation/emul-linux-x86-baselibs
	app-emulation/emul-linux-x86-gtklibs
	app-emulation/emul-linux-x86-opengl
	app-emulation/emul-linux-x86-sdl
	app-emulation/emul-linux-x86-soundlibs
	app-emulation/emul-linux-x86-xlibs
	"

RDEPEND="${COMMON_DEPEND}
	"

DEPEND="${COMMON_DEPEND}
	${DEPEND_SCONSCRIPT}
	${DEPEND_INCLUDE}
	"

S="${WORKDIR}/${DF_PN}_linux"

pkg_setup() {
	multilib_toolchain_setup x86
	games_pkg_setup
}

src_prepare() {
	cp "${FILESDIR}/SConstruct" "SConstruct" || die
	cp "${FILESDIR}/SConscript" "g_src/SConscript" || die
	rm "libs/libgraphics.so" || die
}

src_compile() {
	escons || die
}

src_install() {
	dogameslib.so "libs/libgraphics.so" || die
}
