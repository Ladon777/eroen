# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=(python{2_7,3_2,3_3,3_4})
LIVE=""
[[ ${PV} = 9999* ]] && LIVE=yes
MY_PN=${PN##*-}
if [[ -n ${LIVE} ]]; then
	inherit eutils python-any-r1 subversion games
	ESVN_REPO_URI="http://svn.code.sf.net/p/simutrans/code/${MY_PN}"
else
	inherit eutils games
	MY_PV=${PV/_rc/--RC_}
	SRC_URI="mirror://sourceforge/simutrans/pak128-2.5.2--RC_120.zip"
	SRC_URI="mirror://sourceforge/simutrans/${MY_PN}-${MY_PV}.zip"
	KEYWORDS="-* ~amd64 ~x86"
fi
DESCRIPTION="Simutrans pakset featuring a complex economy and a wide variety of objects"
HOMEPAGE="http://www.simutrans.com/
	http://sourceforge.net/p/simutrans/code/HEAD/tree/pak128/"

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
			)
		${PYTHON_DEPS}
		"
else
	DEPEND="app-arch/unzip"
fi

S=${WORKDIR}

pkg_setup() {
	[[ -n ${LIVE} ]] && python-any-r1_pkg_setup
	games_pkg_setup
}

src_unpack() {
	if [[ -n ${LIVE} ]]; then
		subversion_src_unpack
	else
		default
	fi
}

src_compile() {
	if [[ -n ${LIVE} ]]; then
		${PYTHON} pakmak.py || die
	fi
}

src_install() {
	insinto "${GAMES_DATADIR}"/${PN}
	doins -r simutrans/pak128

	games_make_wrapper ${PN} "simutrans -objects ../${PN}/pak128"
	make_desktop_entry ${PN} "Simutrans (${MY_PN})" simutrans.ico

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "To run Simutrans with ${MY_PN} pakset, execute:"
	elog "    ${PN}"
}
