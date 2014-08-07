# By Eroen, 2012-2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5

inherit scons-utils multilib games

DESCRIPTION="General purpose library used by dwarffortress"
HOMEPAGE="http://www.bay12games.com/dwarves
	http://github.com/Baughn/Dwarf-Fortress--libgraphics-"
SRC_URI="http://www.bay12games.com/dwarves/df_${PV//./_}_linux.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64" # ~x86

HDEPEND="virtual/pkgconfig"
LIBDEPEND="
	media-libs/glew[abi_x86_32]
	virtual/glu[abi_x86_32]
	media-libs/libsdl[abi_x86_32]
	media-libs/libsndfile[abi_x86_32]
	media-libs/openal[abi_x86_32]
	media-libs/sdl-image[abi_x86_32]
	media-libs/sdl-ttf[abi_x86_32]
	sys-libs/ncurses[abi_x86_32]
	sys-libs/zlib[abi_x86_32]
	x11-libs/gtk+:2[abi_x86_32]
	"
RDEPEND="${LIBDEPEND}"
DEPEND="${HDEPEND}
	${LIBDEPEND}
	"

S=${WORKDIR}/df_linux

pkg_setup() {
	multilib_toolchain_setup x86
	games_pkg_setup
}

src_prepare() {
	rm -r data raw || die
	rm g_src/{find_files.cpp,music_and_sound_fmodex.cpp,music_and_sound_fmodex.h} \
		g_src/template.h || die
	rm libs/{Dwarf_Fortress,libgcc_s.so.1,libgraphics.so,libstdc++.so.6} || die
	cp "${FILESDIR}/SConscript" "g_src/SConscript" || die
	cp "${FILESDIR}/SConstruct" "SConstruct" || die
}

src_compile() {
	LIBPATH="$(games_get_libdir)" escons
}

src_install() {
	dogameslib.so "libs/libgraphics.so"
	prepgamesdirs
}
