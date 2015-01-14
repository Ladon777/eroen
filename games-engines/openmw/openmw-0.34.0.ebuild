# By Eroen, 2013-2014
# Distributed under the terms of the ISC license
# $Header: $

EAPI=5

inherit eutils flag-o-matic versionator games cmake-utils
[[ $(get_version_component_range $(get_version_component_count)) == *999? ]] && inherit git-r3

DESCRIPTION="Unofficial open source engine reimplementation of the game Morrowind"
HOMEPAGE="http://openmw.org/"
LICENSE="GPL-3 MIT BitstreamVera"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="installer +launcher minimal +opencs profile test +tr1"

if [[ ${PV} == *999? ]]; then
	EGIT_REPO_URI="git://github.com/OpenMW/openmw.git"
	if [[ $(get_version_component_count) -ge 4 ]]; then
		EGIT_BRANCH=openmw$(get_version_component_range 2)
	fi
else
	SRC_URI="http://github.com/OpenMW/${PN}/archive/${P}.tar.gz"
	S=${WORKDIR}/${PN}-${P}
fi

OPENMW_LIBS=">=dev-games/mygui-3.2.1
	dev-libs/tinyxml
	media-libs/openal
	>=virtual/ffmpeg-0.9
	sci-physics/bullet"
INSTALLER_LIBS="app-arch/unshield
	dev-qt/qtcore
	dev-qt/qtgui"
LAUNCHER_LIBS="dev-qt/qtcore
	dev-qt/qtgui"
OPENCS_LIBS="dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtxmlpatterns"

HDEPEND=""
# boost[threads]: can't test https://bugs.gentoo.org/458404
# libsdl2[-directfb]: https://bugs.gentoo.org/503130
LIBDEPEND="${OPENMW_LIBS}
	installer? ( ${INSTALLER_LIBS} )
	launcher? ( ${LAUNCHER_LIBS} )
	opencs? ( ${OPENCS_LIBS} )
	>=dev-games/ogre-1.9[boost,cg,freeimage,opengl,threads,zip]
	dev-libs/boost:=[threads]
	media-libs/libsdl2[-directfb(-)]"
DEPEND="${LIBDEPEND}
	test? ( dev-cpp/gmock[tr1=]
	    dev-cpp/gtest[tr1=] )"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
RDEPEND="${LIBDEPEND}"

DOCS=""

pkg_setup() {
	if use test && ! use tr1; then
		append-cflags -DGTEST_USE_OWN_TR1_TUPLE=1
		append-cxxflags -DGTEST_USE_OWN_TR1_TUPLE=1
	fi
}

src_prepare() {
	epatch_user
}

src_configure() {
	mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${GAMES_PREFIX}"
		-DDATAROOTDIR="${GAMES_DATADIR_BASE}"
		-DGLOBAL_DATA_PATH="${GAMES_DATADIR}"
		-DDATADIR="${GAMES_DATADIR}/${PN}"
		-DSYSCONFDIR="${GAMES_SYSCONFDIR}"/${PN}
		-DMORROWIND_DATA_FILES="${GAMES_DATADIR}/${PN}/data"
		-DOPENMW_RESOURCE_FILES="${GAMES_DATADIR}/${PN}/resources"
		$(cmake-utils_use_build installer WIZARD)
		$(cmake-utils_use_build launcher LAUNCHER)
		$(cmake-utils_use_build opencs OPENCS)
		$(cmake-utils_use_build !minimal BSATOOL)
		$(cmake-utils_use_build !minimal ESMTOOL)
		$(cmake-utils_use_build !minimal MWINIIMPORTER)
		$(cmake-utils_use_build !minimal MYGUI_PLUGIN)
		$(cmake-utils_use_build !minimal NIFTEST)
		$(cmake-utils_use_with profile CODE_COVERAGE)
		-DUSE_SYSTEM_TINYXML=ON
		$(cmake-utils_use_build test UNITTESTS)
		)
	cmake-utils_src_configure
}

src_test() {
	pushd "${BUILD_DIR}" > /dev/null || die
	./openmw_test_suite || die
	popd > /dev/null || die
}

src_install() {
	cmake-utils_src_install
	rm -rf "${D}"/usr/share/licenses || die
	sed -e "s:resources=resources:resources=${GAMES_DATADIR}/${PN}/resources:" \
		-i "${D}/${GAMES_SYSCONFDIR}"/${PN}/openmw.cfg || die
	prepgamesdirs
	rmdir "${D}/${GAMES_SYSCONFDIR}" || die
}

pkg_postinst() {
	games_pkg_postinst

	if [[ -d ${ROOT%/}/etc/openmw ]]; then
		ewarn
		ewarn "Systemwide configuration was moved from /etc/openmw to ${GAMES_SYSCONFDIR}/${PN}"
		ewarn "Please take any steps necessary to accomodate this."
	fi
}
