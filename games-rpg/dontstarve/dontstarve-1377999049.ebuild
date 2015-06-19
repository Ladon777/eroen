# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils games

DESCRIPTION="An uncompromising wilderness survival game full of science and magic."
HOMEPAGE="http://www.dontstarvegame.com/"
SRC_URI="dontstarve_x64_${PV}.tar.gz"

# BSD MIT - various files in data/scripts/
LICENSE="dontstarve-EULA BSD MIT"
RESTRICT="fetch strip"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+system-fmod"

HDEPEND=""
LIBDEPEND="system-fmod? ( >=media-libs/fmod-4.44.07[designer(+)] )
	virtual/opengl"
	# system libsdl2 breaks input
	# updater wants sys-libs/zlib
DEPEND=""
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

S="${WORKDIR}"/${PN}

src_install() {
	exeinto "${GAMES_BINDIR}"
	newexe "${FILESDIR}"/launcher.sh ${PN}
	sed -e "s:@VAR0@:${GAMES_DATADIR}/${PN}/data:" \
		-e "s:@VAR1@:$(games_get_libdir)/${PN}/${PN}:" \
		-e "s:@VAR2@:$(games_get_libdir)/${PN}:" \
		-i "${D}${GAMES_BINDIR}"/${PN} || die

	insinto "$(games_get_libdir)"/${PN}
	doins bin/dontstarve
	doins bin/lib64/libSDL2{.so,-2.0.so.0{,.0.0}}
	use system-fmod || doins \
		bin/lib64/libfmodevent64{,-4.44.07}.so \
		bin/lib64/libfmodex64{,-4.44.07}.so

	insinto "${GAMES_DATADIR}"/${PN}
	#doins -r data/* # takes a year
	mkdir -p "${D}${GAMES_DATADIR}"/${PN} || die
	cp -r data "${D}${GAMES_DATADIR}"/${PN}/ || die
	cp -r mods "${D}${GAMES_DATADIR}"/${PN}/ || die

	prepgamesdirs
	chmod og+x "${D}$(games_get_libdir)"/${PN}/${PN}
}
