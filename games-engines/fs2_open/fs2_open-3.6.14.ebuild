# Copyright 2012 Eroen
# Distributed under the terms of the BSD 2-clause license
# $Header: $

EAPI=5

inherit eutils versionator games

MY_PV="$(replace_all_version_separators '_')"
MY_P="${PN}_${MY_PV}"

DESCRIPTION="Opensourced engine from Freespace 2"
HOMEPAGE="http://scp.indiegames.us/"
SRC_URI="http://swc.fs2downloads.com/builds/${MY_P}_src.tgz"

LICENSE="fs2_open"
SLOT="0"
KEYWORDS="~amd64"
IUSE="inferno speech doxygen"

COMMON_DEPEND="
	dev-lang/lua
	media-libs/libogg
	media-libs/libpng
	media-libs/libsdl
	media-libs/libtheora
	media-libs/libvorbis
	media-libs/openal
	virtual/glu
	virtual/jpeg
	virtual/opengl
	"
DEPEND="${COMMON_DEPEND}
	sys-devel/automake
	sys-devel/autoconf
	doxygen? ( app-doc/doxygen )
	"
RDEPEND="${COMMON_DEPEND}
	"

S="${WORKDIR}/${MY_P}"

src_prepare () {
	rm -rf libjpeg
	rm -rf libpng
	rm -rf lua
	rm -rf oggvorbis
	rm -rf openal
	rm -rf speech
	rm -rf zlib
	epatch "${FILESDIR}"/${P}-01-remove-spurious-toolchain.patch
}

src_configure () {
	MY_CONF=(
		--disable-debug
		# Editor, fails to -I wx dirs.
		--disable-wxfred2
		$( use_enable inferno )
		$( use_enable speech )
		)

	./autogen.sh
	egamesconf ${MY_CONF[*]}
}

src_compile () {
	emake
	if use doxygen; then
		doxygen -u fs2open.Doxyfile
		doxygen fs2open.Doxyfile
	fi
}

src_install () {
	use inferno && MY_BIN=code/${PN}_${PV}
	! use inferno && MY_BIN=code/${PN}_${PV}_NOINF
	dogamesbin ${MY_BIN}
	dodoc AUTHORS
	dodoc ChangeLog
	dodoc FS2OpenSCPReadMe.doc
	if use doxygen; then
		dodoc -r documentation/doxygen
	fi
}

pkg_postinst () {
	games_pkg_postinst

	elog fs2_open needs to be run from a directory containing the *.vp files
	elog from a Freespace 2 install.
	elog
	elog User data is stored in ~/.fs2_open/
}
