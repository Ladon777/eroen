# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT="python2_7"

inherit eutils games

DESCRIPTION="extracted updater from Don't Starve"
HOMEPAGE="http://www.dontstarvegame.com/"
SRC_URI="dontstarve-updater-18.tar.gz"
RESTRICT="mirror"

LICENSE="dontstarve-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND="dev-python/requests"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

src_prepare() {
	sed -e "s:/usr/lib:$(games_get_libdir):" \
		-i dontstarve-updater || die
}

src_install() {
	exeinto "${GAMES_BINDIR}"
	doexe dontstarve-updater

	insinto "$(games_get_libdir)"/${PN}
	doins *.py cacert.pem

	prepgamesdirs
	chmod ug+x "${D}$(games_get_libdir)"/${PN}/updater.py || die
}
