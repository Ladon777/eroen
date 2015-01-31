# By eroen, 2015
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils java-pkg-2 games

MY_PN=FarSky

DESCRIPTION="Gather resources and protect yourself in the Ocean depths"
HOMEPAGE="http://www.farskygame.com"
SRC_URI="${MY_PN}release.tar"
RESTRICT="bindist fetch"
S=${WORKDIR}

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.5
	>=sys-libs/glibc-2.4
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXxf86vm"

MY_PREFIX=${GAMES_PREFIX_OPT}/$PN
QA_FLAGS_IGNORED="
	${MY_PREFIX}/linux/libjinput-linux.*\.so
	${MY_PREFIX}/linux/liblwjgl.*\.so
	${MY_PREFIX}/linux/libopenal.*\.so
	"
QA_PRESTRIPPED="
	${MY_PREFIX}/linux/libjinput-linux.*\.so
	${MY_PREFIX}/linux/liblwjgl.*\.so
	"

pkg_nofetch() {
	elog "Please download ${SRC_URI}"
	elog "from ${HOMEPAGE} or http://humblebundle.com"
	elog "and place it in ${DISTDIR}"
}

pkg_setup() {
	games_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	default
	( set +x ; while true ; do echo n || break ; done ) | \
		unzip -qo "$S"/FarSky/FarSky.jar || die "failed to unzip FarSky.jar"
	( set +x ; while true ; do echo n || break ; done ) | \
		unzip -qo  "$S"/installFiles/libraries.zip || die "failed to unzip libraries.zip"
}

src_prepare() {
	for f in native/linux/*; do
		if [[ $f = *64.so ]]; then
			use amd64 || rm -f "$f" || die "failed to delete $f"
		elif [[ $f = *.so ]]; then
			use x86 || rm -f "$f" || die "failed to delete $f"
		fi
	done
	java-pkg-2_src_prepare
}

src_install() {
	insinto "$MY_PREFIX"
	doins installFiles/version.html
	doins -r native/linux

	java-pkg_jarinto "$MY_PREFIX"/jar
	java-pkg_dojar lib/{jogg-0.0.7,jorbis-0.0.15,lwjgl,lwjgl_util,slick-util}.jar
	java-pkg_jarinto "$MY_PREFIX"
	java-pkg_dojar ./installFiles/farsky.jar
	echo "mkdir -p \${HOME}/.FarSky 2>/dev/null" > "$T"/prelaunch.sh || die
	java-pkg_dolauncher $PN \
		-into "${GAMES_BINDIR%/?*}" \
		-pre "$T"/prelaunch.sh \
		--java_args "-Djava.library.path=$MY_PREFIX/linux -Dsun.java2d.d3d=false" \
		--pkg_args "-param -path:\${HOME}/.FarSky/ -logPath:\${HOME}/.FarSky/log" \
		--jar farsky.jar \
		--main game.Main
	make_desktop_entry $PN FarSky
	prepgamesdirs
}

pkg_preinst() {
	java-pkg-2_pkg_preinst
	games_pkg_preinst
}
