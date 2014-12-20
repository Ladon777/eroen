# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils flag-o-matic gnome2-utils games

MY_PV=${PV##0.}
MY_PV=${MY_PV//./-}
DESCRIPTION="A free Transport Tycoon clone"
HOMEPAGE="http://www.simutrans.com/"
SRC_URI="mirror://sourceforge/simutrans/simutrans-src-${MY_PV}.zip
	mirror://sourceforge/simutrans/simulinux-i86-${MY_PV}.zip
	mirror://sourceforge/simutrans/simupak64-${MY_PV}.zip"

LICENSE="Artistic MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="sdl2"

RDEPEND="
	sdl2? (
		media-libs/libsdl2[opengl,sound,video]
		)
	!sdl2? (
		media-libs/libsdl[sound,video]
		media-libs/sdl-mixer
		)
	sys-libs/zlib
	app-arch/bzip2
	"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}

src_prepare() {
	strip-flags # bug #293927

	# make it look in the install location for the data
	sed -i \
		-e "s:argv\[0\]:\"${GAMES_DATADIR}/${PN}/\":" \
		simmain.cc || die

	epatch \
		"${FILESDIR}"/${P}-Makefile.patch
	rm -f simutrans/{simutrans,*.txt}
	mv simutrans/get_pak.sh "${T}" || die
}

src_configure() {
	sh configure.sh || die

	local backend
	if use sdl2; then
		backend=sdl2
	else
		backend=mixer_sdl
	fi
	sed -e '/^DEBUG/d' \
		-e '/^OPTIMISE/d' \
		-e '/^BACKEND/s/=.*$/= '"${backend}"'/' \
		-i config.default || die
	echo 'VERBOSE = 1' >> config.default
}

src_install() {
	newgamesbin sim ${PN}
	dogamesbin "${T}"/get_pak.sh
	insinto "${GAMES_DATADIR}"/${PN}
	doins -r simutrans/*
	dodoc documentation/*
	doicon simutrans.ico
	make_desktop_entry simutrans Simutrans simutrans.ico
	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
