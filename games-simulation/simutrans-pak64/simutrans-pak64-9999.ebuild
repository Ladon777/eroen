# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

LIVE=""
[[ ${PV} = 9999* ]] && LIVE=yes
MY_PN=${PN##*-}
if [[ -n ${LIVE} ]]; then
	inherit eutils subversion games
	ESVN_REPO_URI="http://svn.code.sf.net/p/simutrans/code/${MY_PN}"
else
	inherit eutils games
	MY_PV=${PV##0.}
	MY_PV=${MY_PV//./-}
	SRC_URI="mirror://sourceforge/simutrans/simupak64-${MY_PV}.zip"
	KEYWORDS="-* ~amd64 ~x86"
fi
DESCRIPTION="Official Simutrans pakset"
HOMEPAGE="http://www.simutrans.com/
	http://sourceforge.net/p/simutrans/code/HEAD/tree/pak64/"

LICENSE="Artistic"
SLOT="0"
IUSE=""

RDEPEND="
	>=games-simulation/simutrans-0.120
	"
if [[ -n ${LIVE} ]]; then
	DEPEND="|| (
			games-util/makeobj
			games-simulation/simutrans[makeobj(-)]
			)"
else
	DEPEND="app-arch/unzip"
fi

S=${WORKDIR}

src_unpack() {
	if [[ -n ${LIVE} ]]; then
		subversion_src_unpack
	else
		default
	fi
}

src_prepare() {
	if [[ -n ${LIVE} ]]; then
		# we don't need to generate the zip and tarballs
		echo '.PHONY: gentoo' >> Makefile
		echo 'gentoo: copy $(DIRS)' >> Makefile
	fi
}

src_compile() {
	if [[ -n ${LIVE} ]]; then
		mkdir build
		MAKEOBJ=$(which makeobj) \
			emake -j1 gentoo
	fi
}

src_install() {
	insinto "${GAMES_DATADIR}"/${PN}
	doins -r simutrans/pak

	games_make_wrapper ${PN} "simutrans -objects ../${PN}/pak"
	make_desktop_entry ${PN} "Simutrans (${MY_PN})" simutrans.ico

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "To run Simutrans with ${MY_PN} pakset, execute:"
	elog "    ${PN}"
}
