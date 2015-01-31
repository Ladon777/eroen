# By eroen, 2015
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils games

MY_PN=TypeRider

DESCRIPTION="Platform game with two dots travelling through time and typography"
HOMEPAGE="http://www.bulkypix.com/game/typerider"
SRC_URI="${MY_PN}_linux_${PV}.tar.gz"
RESTRICT="bindist fetch"
S=${WORKDIR}/${MY_PN}

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

# xdg-utils is optional, used for launching a browser
RDEPEND="
	>=sys-devel/gcc-4.5.1[cxx]
	>=sys-libs/glibc-2.11
	virtual/glu
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXcursor
	x11-misc/xdg-utils
	"
DEPEND=""
# GLIBC_2.11
# GLIBCXX_3.4.14

MY_PREFIX=${GAMES_PREFIX_OPT}/${PN}
MY_ARCH=${ARCH/amd64/x86_64}

QA_FLAGS_IGNORED="
	${MY_PREFIX}/TypeRider\.${MY_ARCH}
	${MY_PREFIX}/TypeRider_Data/Mono/${MY_ARCH}/.*
	"
QA_PRESTRIPPED="
	${MY_PREFIX}/TypeRider\.${MY_ARCH}
	${MY_PREFIX}/TypeRider_Data/Mono/${MY_ARCH}/.*
	"

pkg_nofetch() {
	elog "Please download ${A}"
	elog "from ${HOMEPAGE} or http://humblebundle.com"
	elog "and place it in ${DISTDIR}"
}

src_prepare() {
	rm -rf TypeRider_Data/Plugins || die # Seems unused
	local f d
	for f in TypeRider.*; do
		[[ $f = *${MY_ARCH} ]] && continue
		rm -f "$f" || die "Failed to remove $f"
	done
	for d in TypeRider_Data/Mono/*; do
		[[ $d = *${MY_ARCH} ]] && continue
		rm -rf "$d" || die "Failed to remove $d"
	done
}

src_install() {
	insinto "$MY_PREFIX"
	doins -r .

	#into "$GAMES_BINDIR"
	#dosym "$MY_PREFIX"/TypeRider.${MY_ARCH} $PN
	games_make_wrapper $PN "$MY_PREFIX"/TypeRider.${MY_ARCH}
	make_desktop_entry $PN "Type:Rider" "${MY_PREFIX}"/TypeRider_Data/Resources/UnityPlayer.png

	prepgamesdirs
	fperms g+x "$MY_PREFIX"/TypeRider.${MY_ARCH}
}
