# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit games versionator

MY_PN="df"
MY_PV="$(replace_all_version_separators '_')"
MY_P="${MY_PN}_${MY_PV}"

DESCRIPTION="Part roguelike, part city-building game set in a procedurally generated high fantasy universe."
HOMEPAGE="http://www.bay12games.com/dwarves/"
SRC_URI="http://www.bay12games.com/dwarves/${MY_P}_linux.tar.bz2"

LICENSE="DwarfFortress as-is LGPL-2.1 BSD fmod MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libgraphics"
RESTRICT="strip"

DEPEND="libgraphics? ( !dev-libs/libgraphics )
	app-emulation/emul-linux-x86-baselibs
	app-emulation/emul-linux-x86-gtklibs
	app-emulation/emul-linux-x86-opengl
	app-emulation/emul-linux-x86-sdl
	app-emulation/emul-linux-x86-soundlibs
	app-emulation/emul-linux-x86-xlibs
	"
RDEPEND="${DEPEND}
	!libgraphics? ( ~dev-libs/libgraphics-${PV} )
	"

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

src_prepare() {
	sed -f - -i df << EOF
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
