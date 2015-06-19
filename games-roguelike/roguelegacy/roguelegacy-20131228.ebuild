# By eroen, 2014
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils games

DESCRIPTION="A genealogical rogue-LITE where anyone can be a hero."
HOMEPAGE="http://www.roguelegacy.com/"
SRC_URI="${PN}-${PV:4:4}${PV:0:4}-bin"
RESTRICT="fetch mirror"
S=${WORKDIR}

### Bundled stuff
# openal: LGPL-2
# mono:
# libsdl2: ZLIB
# monogame: 
LICENSE="all-rights-reserved LGPL-2 ZLIB"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

HDEPEND="app-arch/unzip"
LIBDEPEND="
	media-libs/alsa-lib
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXcursor
	x11-libs/libXinerama
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXxf86vm
	virtual/opengl
	sys-apps/dbus
	virtual/libudev
	"
DEPEND=""
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
# libSDL2-2.0.so.0: libX11.so.6 libXext.so.6 libXcursor.so.1 libXinerama.so.1 libXi.so.6 libXrandr.so.2 libXxf86vm.so.1 libdbus-1.so.3 libGL.so.1 libudev.so libasound.so.2 # libpulse-simple.so.0 libartsc.so.0 libesd.so.0
# libopenal.so.1: libasound.so.2 # libportaudio.so.2 libpulse.so.0
# System.dll: libasound.so.2

# x86 textrels
QA_PREBUILT="opt/roguelegacy-20131228/data/lib/libmono-*"

pkg_nofetch() {
	elog "Please download ${SRC_URI}"
	elog "from ${HOMEPAGE} or http://humblebundle.com"
	elog "and place it in ${DISTDIR}"
}

src_unpack() {
	# Lifted from portage's unpack().
	# 'unzip' returns 1 due to the initial junk data in the archive.
	( set +x ; while true ; do echo n || break ; done ) | \
		unzip -qo "${DISTDIR}/${A}"
	[[ $? == 0 || $? == 1 ]] || die "unzip failed."
}

src_prepare() {
	# Installer leftovers
	rm -rf guis/ meta/ scripts/ || die

	# Unused stuff
	rm -f data/Lidgren.Network.dll || die
	rm -f data/Mono.{Posix,Security}.dll || die
	rm -f data/System.{Data,Design,Drawing,Management,Runtime.Serialization,Security,Transactions,Xml.Linq}.dll || die

	# We make our own wrapper later.
	rm -f data/RogueLegacy || die

	if ! use amd64; then
		rm -f data/RogueCastle.bin.x86_64 || die
		rm -rf data/lib64/ || die
	fi
	if ! use x86; then
		rm -f data/RogueCastle.bin.x86 || die
		rm -rf data/lib/ || die
	fi
}

src_install() {
	MY_PREFIX=${GAMES_PREFIX_OPT}/${P}

	dodoc data/Linux.README
	rm -f data/Linux.README || die

	insinto "${MY_PREFIX}"
	doins -r *

	use amd64 && games_make_wrapper ${P} ./RogueCastle.bin.x86_64 "${MY_PREFIX}"/data
	use x86 && games_make_wrapper ${P} ./RogueCastle.bin.x86 "${MY_PREFIX}"/data
	make_desktop_entry ${P} ${P} "${MY_PREFIX}/data/Rogue Legacy.bmp"

	prepgamesdirs
	chmod 750 "${ED%/}/${MY_PREFIX}"/data/RogueCastle.bin* || die
}
