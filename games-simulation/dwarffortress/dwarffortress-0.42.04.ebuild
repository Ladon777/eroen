# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils flag-o-matic pax-utils games multilib versionator

MY_PV=$(replace_all_version_separators _ "$(get_version_component_range 2-)")
MY_PN=df
MY_P=${MY_PN}_${MY_PV}

DESCRIPTION="A single-player fantasy game"
HOMEPAGE="http://www.bay12games.com/dwarves"
SRC_URI="http://www.bay12games.com/dwarves/${MY_P}_linux.tar.bz2"

LICENSE="free-noncomm BSD BitstreamVera"
SLOT="$PV"
KEYWORDS="~amd64 ~x86 -*"
IUSE="debug"

RDEPEND="media-libs/glew[abi_x86_32(-)]
	media-libs/libsdl[abi_x86_32(-),opengl,video,X]
	media-libs/libsndfile[abi_x86_32(-),alsa]
	media-libs/sdl-image[abi_x86_32(-),jpeg,png,tiff]
	media-libs/sdl-ttf[abi_x86_32(-)]
	sys-libs/zlib[abi_x86_32(-)]
	virtual/glu[abi_x86_32(-)]
	x11-libs/gtk+:2[abi_x86_32(-)]"
# Yup, openal and ncurses are only needed at compile-time; the code dlopens it at runtime
# if requested.
DEPEND="${RDEPEND}
	media-libs/openal[abi_x86_32(-)]
	sys-libs/ncurses[abi_x86_32(-),unicode]
	virtual/pkgconfig
	x11-proto/kbproto[abi_x86_32(-)]
	x11-proto/xproto[abi_x86_32(-)]"

S=${WORKDIR}/${MY_PN}_linux

gamesdir="${GAMES_PREFIX_OPT}/${PN}-${SLOT}"
QA_PRESTRIPPED="${gamesdir}/libs/Dwarf_Fortress"
RESTRICT="strip"

pkg_setup() {
	games_pkg_setup

	multilib_toolchain_setup x86

	# dfhack needs symbols that are removed from libgraphics with optimization
	filter-flags '-O*'
}

src_prepare() {
	rm -f libs/*.so* || die
	cp "${FILESDIR}"/Makefile . || die
	cp "${FILESDIR}"/dwarffortress2.sh ./dwarffortress || die
	epatch_user
}

src_configure() {
	sed -i -e "s/@@SLOT@@/${SLOT}/g" ./dwarffortress || die

	tc-export CXX PKG_CONFIG
	CXXFLAGS+=" -D$(use debug || echo N)DEBUG"
}

src_install() {
	# install data-files and libs
	insinto "${gamesdir}"
	doins -r raw data libs

	# install our wrapper
	newgamesbin ./dwarffortress dwarffortress-${SLOT}

	# install docs
	dodoc README.linux *.txt

	prepgamesdirs

	fperms 750 "${gamesdir}"/libs/Dwarf_Fortress
	
	# PAX marking for dfhack. PTPAX markings change the md5 hash of the
	# executable, and breaks version detection in dfhack
	PAX_MARKINGS=XT pax-mark -m "${ED%/}${gamesdir}"/libs/Dwarf_Fortress
}

pkg_postinst() {
	elog "System-wide Dwarf Fortress has been installed to ${gamesdir}. This is"
	elog "symlinked to ~/.dwarffortress-${SLOT} when dwarffortress-${SLOT} is run."
	elog "For more information on what exactly is replaced, see ${GAMES_BINDIR}/dwarffortress-${SLOT}."
	elog "Note: This means that the primary entry point is ${GAMES_BINDIR}/dwarffortress-${SLOT}."
	elog "Do not run ${gamesdir}/libs/Dwarf_Fortress."
	elog
	elog "Optional runtime dependencies: install sys-libs/ncurses[$(use amd64 && echo "abi_x86_32,")unicode]"
	elog "for [PRINT_MODE:TEXT]. Install media-libs/openal$(use amd64 && echo "[abi_x86_32]") for audio output."
	elog
	games_pkg_postinst
}
