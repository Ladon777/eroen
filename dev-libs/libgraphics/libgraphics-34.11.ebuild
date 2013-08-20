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
IUSE="egg"

DEPEND_SCONSCRIPT="virtual/pkgconfig
	media-libs/sdl-image
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
	"

COMMON_DEPEND="!games-simulation/dwarffortress[libgraphics]
	egg? ( games-util/dfhack[egg] )
	app-emulation/emul-linux-x86-gtklibs
	app-emulation/emul-linux-x86-opengl
	app-emulation/emul-linux-x86-sdl
	|| ( dev-libs/glib[abi_x86_32(-)] app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )
	|| ( sys-libs/zlib[abi_x86_32(-)] app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )"

	#||( media-libs/glu app-emulation/emul-linux-x86-opengl ) # or virtual/glu ?
	#||( media-libs/glew app-emulation/emul-linux-x86-opengl )
	#||( media-libs/mesa app-emulation/emul-linux-x86-opengl ) # or virtual/opengl ?
	#||( media-libs/libsdl app-emulation/emul-linux-x86-sdl )
	#||( media-libs/sdl-image app-emulation/emul-linux-x86-sdl )
	#||( media-libs/sdl-ttf app-emulation/emul-linux-x86-sdl )
	#||( x11-libs/gtk+ app-emulation/emul-linux-x86-gtklibs )

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
	if use egg; then
		epatch "${FILESDIR}/0001-Add-something-eggy.patch"
		cp "${FILESDIR}/SConscript-egg" "g_src/SConscript" || die
	else
		cp "${FILESDIR}/SConscript" "g_src/SConscript" || die
	fi
	cp "${FILESDIR}/SConstruct" "SConstruct" || die
	rm "libs/libgraphics.so" || die
}

src_compile() {
	LIBPATH="$(games_get_libdir)" escons || die
}

src_install() {
	dogameslib.so "libs/libgraphics.so" || die
}
