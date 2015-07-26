# By eroen, 2015
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils java-pkg-2 games

MY_PV=${PV//./_}

DESCRIPTION="Medieval/fantasy real time city building/strategy game"
HOMEPAGE="http://hearthlands.com"
SRC_URI="hearthlands_${MY_PV}.tar.gz"
S=$WORKDIR

LICENSE="all-rights-reserved" # eula and others in tarball
RESTRICT="bindist fetch mirror"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

HDEPEND=""
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}
	>=virtual/jre-1.6
	media-libs/openal
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXxf86vm
	x11-apps/xrandr
	"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

QA_PRESTRIPPED="${GAMES_PREFIX_OPT#/}/$PN/lib/.*\\.so"

pkg_nofetch() {
	einfo "Please obtain"
	einfo "    $A"
	einfo "from"
	einfo "    $HOMEPAGE or http://www.humblebundle.com"
	einfo "and place it in"
	einfo "    $DISTDIR"
}

pkg_setup() {
	java-pkg-2_pkg_setup
	games_pkg_setup
}

src_prepare() {
	rm -f bin/natives/{libopenal64.so,libopenal.so} || die
	if ! use amd64; then
		rm -f bin/natives/{libjinput-linux64.so,liblwjgl64.so} || die
	fi
	#if ! use x86; then
		rm -f bin/natives/{libjinput-linux.so,liblwjgl.so} || die
	#fi

	echo "[ -d \"\${HOME}\"/.$PN ] || mkdir -p \"\${HOME}\"/.$PN" >> "$T"/prelaunch.sh
	echo "cd \"\${HOME}\"/.$PN" >> "$T"/prelaunch.sh
	echo "[ -e config.txt ] || cp \"$GAMES_DATADIR\"/$PN/config.txt config.txt" >> "$T"/prelaunch.sh
	echo "[ -e en.tsv ] || ln -s \"$GAMES_DATADIR\"/$PN/en.tsv en.tsv" >> "$T"/prelaunch.sh

	java-pkg-2_src_prepare
}

src_install() {
	java-pkg_jarinto "$GAMES_PREFIX_OPT"/$PN/lib
	java-pkg_dojar bin/*.jar
	java-pkg_sointo "$GAMES_PREFIX_OPT"/$PN/lib
	java-pkg_doso bin/natives/*.so
	java-pkg_dolauncher $PN \
		--main com.hearthlands.game.GameMain \
		--jar Hearthlands.jar \
		-into "$GAMES_PREFIX" \
		-pre "$T"/prelaunch.sh

	insinto "$GAMES_DATADIR"/$PN
	doins config.txt en.tsv

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	java-pkg-2_pkg_preinst
}
