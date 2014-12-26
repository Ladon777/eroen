# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils games

MY_PV=${PV##0.}
MY_PV=${MY_PV//./-}
DESCRIPTION="Tool for creating Simutrans paksets."
# This is separate from simutrans due to different compile-time -Defines and
# a non-functional wish-it-were out-of-source build system.
HOMEPAGE="http://www.simutrans.com/"
SRC_URI="mirror://sourceforge/simutrans/simutrans-src-${MY_PV}.zip"

LICENSE="Artistic MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

RDEPEND="
	app-arch/bzip2
	media-libs/libpng:0
	sys-libs/zlib
	"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}

src_prepare() {
	# make it look in the install location for the data
	sed -i \
		-e "s:argv\[0\]:\"${GAMES_DATADIR}/${PN}/\":" \
		simmain.cc || die

	edos2unix Makefile makeobj/Makefile
	epatch \
		"${FILESDIR}"/simutrans-${PV}-Makefile.patch \
		"${FILESDIR}"/${P}-Makefile.patch \
		"${FILESDIR}"/${P}-Makefile-2.patch
}

src_configure() {
	sh configure.sh || die

	local backend
	#if use sdl2; then
	#	backend=sdl2
	#elif use sound; then
	#	backend=mixer_sdl
	#else
	#	backend=sdl
	#fi
	backend=posix
	sed -e '/^BACKEND/s/=.*$/= '"${backend}"'/' \
		-i config.default || die

	sed -e '/^DEBUG/d' \
		-e '/^OPTIMISE/d' \
		-i config.default || die
	echo 'VERBOSE = 1' >> config.default
}

src_compile() {
	emake makeobj
}

src_install() {
	# This must be available for use by package manager.
	dobin makeobj/makeobj

	prepgamesdirs
}
