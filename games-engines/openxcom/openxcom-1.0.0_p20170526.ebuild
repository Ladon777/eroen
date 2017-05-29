# Copyright 1999-2016 Gentoo Foundation
# eroen, 2017
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils cmake-utils gnome2-utils vcs-snapshot

DESCRIPTION="An open-source reimplementation of the popular UFO: Enemy Unknown"
HOMEPAGE="http://openxcom.org/"
SRC_URI="https://codeload.github.com/SupSuper/OpenXcom/tar.gz/75d727864e4a6e6ebf6107956227f35ef959a9c0 -> $P.tar.gz"

LICENSE="GPL-3 CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=dev-cpp/yaml-cpp-0.5.1
	media-libs/libsdl2[opengl,video]
	media-libs/sdl2-gfx
	media-libs/sdl2-image[png]
	media-libs/sdl2-mixer[flac,mikmod,vorbis]
	virtual/opengl
	"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

DOCS=( )

src_configure() {
	local mycmakeargs=(
		-DDEV_BUILD=OFF
		-DBUILD_PACKAGE=OFF
		)
	cmake-utils_src_configure
}

src_compile() {
	use doc && cmake-utils_src_compile doxygen
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	use doc && dodoc -r "${CMAKE_BUILD_DIR}"/docs/html/*
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	echo
	elog "In order to play you need copy GEODATA, GEOGRAPH, MAPS, ROUTES, SOUND,"
	elog "TERRAIN, UFOGRAPH, UFOINTRO, UNITS folders from original X-COM game to"
	elog "${EPREFIX%/}/usr/share/openxcom/UFO"
	echo
	elog "If you need or want text in some language other than english, download:"
	elog "http://openxcom.org/translations/latest.zip and uncompress it in"
	elog "${EPREFIX%/}/usr/share/openxcom/common/Language"
}

pkg_postrm() {
	gnome2_icon_cache_update
}
