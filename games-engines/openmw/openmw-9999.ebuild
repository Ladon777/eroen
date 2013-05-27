# By Eroen, 2013
# Distributed under the terms of the ISC license
# $Header: $

EAPI=5

inherit eutils games cmake-utils
[ ${PV:0:3} == 999 ] && inherit git-2

DESCRIPTION="Unofficial open source engine reimplementation of the game Morrowind"
HOMEPAGE="https://openmw.org/"
LICENSE="GPL-3 BitstreamVera DaedricFont OFL-1.1"
SLOT="0"
KEYWORDS=""
IUSE="test"

if [ ${PV:0:3} == 999 ]; then
	S="${WORKDIR}"/${PN}
	EGIT_REPO_URI="git://github.com/zinnschlag/openmw.git"
else
	SRC_URI="https://openmw.googlecode.com/files/${P}.tar.gz"
	S="${WORKDIR}"/${PN}-${P}
fi

HDEPEND=">=dev-util/cmake-2.8"
LIBDEPEND="dev-games/ogre[boost,cg,freeimage,ois,opengl,threads,zip]
	dev-games/mygui
	dev-libs/boost[threads]
	media-libs/openal
	sci-physics/bullet
	virtual/ffmpeg
	dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtxmlpatterns"
DEPEND="${LIBDEPEND}
	test? ( dev-cpp/gmock
	    dev-cpp/gtest )"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
RDEPEND="${LIBDEPEND}"

src_prepare() {
	epatch_user
}

src_configure() {
	mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-DDATAROOTDIR="${GAMES_DATADIR}"
		-DDATADIR="${GAMES_DATADIR}/${PN}"
		-DSYSCONFDIR="${GAMES_SYSCONFDIR}"/${PN}
		$(cmake-utils_use_build test UNITTESTS)
		)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	sed -e "s:resources=resources:resources=${GAMES_DATADIR}/${PN}/resources:" \
		-i "${D}/${GAMES_SYSCONFDIR}"/${PN}/openmw.cfg || die "sed failed"
	prepgamesdirs
	mv -t "${D}"/etc "${D}/${GAMES_SYSCONFDIR}"/${PN} || die "mv conf from gamedir failed"
	rmdir "${D}/${GAMES_SYSCONFDIR}" || die "rmdir games confdir failed"
}
