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
IUSE="freetype sdl2 +sound"

RDEPEND="
	freetype? (
		media-libs/freetype:2
		)
	sdl2? (
		media-libs/libsdl2[opengl,video]
		sound? (
			media-libs/libsdl2[opengl,sound,threads,video]
			)
		)
	!sdl2? (
		media-libs/libsdl[sound,video]
		sound? (
			media-libs/libsdl[sound,video]
			media-libs/sdl-mixer[midi]
			)
		)
	sys-libs/zlib
	app-arch/bzip2
	"
DEPEND="${RDEPEND}
	freetype? (
		virtual/pkgconfig
		)
	app-arch/unzip"

S=${WORKDIR}

src_prepare() {
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
	elif use sound; then
		backend=mixer_sdl
	else
		backend=sdl
	fi
	sed -e '/^BACKEND/s/=.*$/= '"${backend}"'/' \
		-i config.default || die

	if use freetype; then
		cat >> config.default <<-EOF
			FLAGS += -DUSE_FREETYPE
			CFLAGS += \$(shell pkg-config freetype2 --cflags)
			CXXFLAGS += \$(shell pkg-config freetype2 --cflags)
			LIBS += \$(shell pkg-config freetype2 --libs)
			EOF
	fi

	sed -e '/^DEBUG/d' \
		-e '/^OPTIMISE/d' \
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

	if use sound && use sdl2; then
		ewarn
		ewarn "You have selected the sdl2 backend for ${PN}."
		ewarn "This backend does not support playing midi background music."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
