# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils versionator games

DESCRIPTION="An uncompromising wilderness survival game full of science and magic."
HOMEPAGE="http://www.dontstarvegame.com/"
SRC_URI="dontstarve_x64_$(get_major_version).tar.gz"

# BSD MIT - various files in data/scripts/
LICENSE="dontstarve-EULA BSD MIT"
RESTRICT="fetch strip"
SLOT="0"
#KEYWORDS="-* ~amd64"
IUSE="+system-fmod"

if [[ "$(get_version_components 2)" == "9999" ]]; then
	LIVE=yes
fi

HDEPEND=""
[[ -n "${LIVE}" ]] && HDEPEND+=" games-util/dontstarve-updater-ng"
LIBDEPEND="system-fmod? ( >=media-libs/fmod-4.44.07[designer(+)] )
	virtual/opengl"
	# system libsdl2 breaks input
	# updater wants sys-libs/zlib
DEPEND=""
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

S="${WORKDIR}"/${PN}

pkg_pretend() {
	default
	if [[ -n "${LIVE}" ]] && ! [[ -n "${dontstarve_KEY}" ]]; then
		eerror "dontstarve_KEY is not set, but a live install is requested."
		die
	fi
}

src_unpack() {
	default

	if [[ -n "${LIVE}" ]]; then
		einfo "Will run dontstarve-updater-ng to fetch latest version"
		pushd "${S}" || die
		mkdir -p ~/.klei/DoNotStarve || die
		echo -n "{\"key\": \"${dontstarve_KEY}\"}" > ~/.klei/DoNotStarve/updater.json
		/usr/games/bin/dontstarve-updater-ng --checkconsistency || die \
			"the updater failed. It does that sometimes, perhaps trying again helps."
		popd || die
	fi
}

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
