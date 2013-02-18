# By Eroen, 2013
# Distributed under the terms of the ISC license
# $Header: $

EAPI=5 # -hdepend nerfed by eclasses

inherit eutils games cmake-utils
[ ${PV} -ge 9998 ] && inherit git-2

DESCRIPTION="Unofficial open source engine reimplementation of the game Morrowind"
HOMEPAGE="https://openmw.org/"
LICENSE="GPL-3 BitstreamVera DaedricFont OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

if [ ${PV} -ge 9998 ]; then
	EGIT_REPO_URI="git://github.com/zinnschlag/openmw.git"
	[ ${PV} -eq 9999 ] && EGIT_BRANCH="next"
else
	SRC_URI="https://openmw.googlecode.com/files/${PN}_${PV}.orig.tar.bz2"
fi

HDEPEND=">=dev-util/cmake-2.8"
LIBDEPEND="dev-games/ogre[boost,cg,freeimage,ois,opengl,threads,zip]
	dev-games/mygui
	dev-libs/boost[threads]
	media-libs/openal
	sci-physics/bullet
	virtual/ffmpeg
	x11-libs/qt-core
	x11-libs/qt-gui
	x11-libs/qt-xmlpatterns"
DEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
RDEPEND="${LIBDEPEND}"
#test: gmock gtest

src_prepare() {
	epatch "${FILESDIR}"/0001-fix-BINDIR.patch
	epatch "${FILESDIR}"/0002-libc-fixes.patch
	epatch_user
}

src_configure() {
	mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-DDATAROOTDIR="${GAMES_DATADIR}"
		-DSYSCONFDIR="${GAMES_SYSCONFDIR}"/${PN}
		)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	sed -e "s:resources=resources:resources=${GAMES_DATADIR}/${PN}/resources:" \
		-i "${D}/${GAMES_SYSCONFDIR}"/${PN}/openmw.cfg || die "sed failed"
	prepgamesdirs
	mv -t "${D}"/etc "${D}/${GAMES_SYSCONFDIR}"/${PN} || die "mv failed"
	rmdir "${D}/${GAMES_SYSCONFDIR}" || die "rmdir failed"
}
