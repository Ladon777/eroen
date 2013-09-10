# By Eroen, 2012-2013
# Distributed under the terms of the ISC license
# $Header: $

EAPI=5

inherit games versionator multilib

MY_PN="df"
MY_PV="$(replace_all_version_separators '_')"
MY_P="${MY_PN}_${MY_PV}"

DESCRIPTION="Part roguelike, part city-building game set in a procedurally generated high fantasy universe."
HOMEPAGE="http://www.bay12games.com/dwarves/"
SRC_URI="http://www.bay12games.com/dwarves/${MY_P}_linux.tar.bz2"

# LGPL-2.1 (for sdl) and fmod are explicitly claimed by the readme.
LICENSE="DwarfFortress fmod LGPL-2.1 BitstreamVera"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libgraphics"
RESTRICT="strip"

DEPEND="libgraphics? ( !dev-libs/libgraphics )
	app-emulation/emul-linux-x86-sdl"
RDEPEND="${DEPEND}
	!libgraphics? ( ~dev-libs/libgraphics-${PV} )
	>=sys-devel/gcc-4.5"

S="${WORKDIR}/${MY_PN}_linux"
MY_DATADIR="${GAMES_DATADIR}/${P}"
MY_STATEDIR="${GAMES_STATEDIR}/${P}"
MY_SYSCONFDIR="${GAMES_SYSCONFDIR}/${P}"

absdf="${GAMES_BINDIR}/Dwarf_Fortress"
QA_PREBUILT+=" ${absdf#/}"
if use libgraphics; then
	abslg="$( games_get_libdir )/libgraphics.so"
	QA_PREBUILT+=" ${abslg#/}"
fi

pkg_setup() {
	games_pkg_setup
	multilib_toolchain_setup x86
}

src_prepare() {
	sed -f - -i df << EOF || die
s:DF_DIR=.*:DF_DIR="${MY_DATADIR}":
s:./libs/Dwarf_Fortress:"${GAMES_BINDIR}/Dwarf_Fortress":
s:^export SDL_DISABLE_LOCK_KEYS=1:#&:
EOF
}

src_install() {
	dogamesbin "libs/Dwarf_Fortress" || die
	if use libgraphics; then
		dogameslib.so "libs/libgraphics.so" || die
	fi
	newgamesbin "df" "df-${PV}" || die

	insinto "${MY_SYSCONFDIR}"
	doins -r "data/init"
	rm -r "data/init"

	insinto "${MY_STATEDIR}"
	doins "data/index" || die
	rm "data/index" || die
	keepdir "${MY_STATEDIR}/save" || die
	doins -r "data/movies" || die
	rm -r "data/movies" || die
	keepdir "${MY_STATEDIR}/objects" || die
	doins -r "data/announcement" || die
	rm -r "data/announcement" || die
	doins -r "data/help" || die
	rm -r "data/help" || die
	doins -r "data/dipscript" || die
	rm -r "data/dipscript" || die

	insinto "${MY_DATADIR}"
	doins -r data || die
	dosym "${MY_STATEDIR}/gamelog.txt" "${MY_DATADIR}/gamelog.txt" || die
	dosym "${MY_SYSCONFDIR}/init" "${MY_DATADIR}/data/init" || die
	dosym "${MY_STATEDIR}/index" "${MY_DATADIR}/data/index" || die
	dosym "${MY_STATEDIR}/save" "${MY_DATADIR}/data/save" || die
	dosym "${MY_STATEDIR}/movies" "${MY_DATADIR}/data/movies" || die
	dosym "${MY_STATEDIR}/objects" "${MY_DATADIR}/data/objects" || die
	dosym "${MY_STATEDIR}/announcement" "${MY_DATADIR}/data/announcement" || die
	dosym "${MY_STATEDIR}/help" "${MY_DATADIR}/data/help" || die
	dosym "${MY_STATEDIR}/dipscript" "${MY_DATADIR}/data/dipscript" || die

	doins -r "raw" || die

	prepgamesdirs
	fperms -R g+w "${MY_STATEDIR}" || die

	dodoc "README.linux"
	dodoc *".txt"

}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "For pulseaudio output, you may want to add 'drivers=pulse'"
	elog "to your /etc/openalrc."
	elog
	elog "To start Dwarf Fortress, please run 'df-${PV}'"
	echo
}
