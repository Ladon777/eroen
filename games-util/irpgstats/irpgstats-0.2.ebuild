# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT=(python2_7 python3_2 python3_3)

inherit eutils distutils-r1 games

DESCRIPTION="IdleRPG db parser and pretty-printer"
HOMEPAGE="http://eroen.eu"
SRC_URI="${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND="python_targets_python2_7? ( dev-python/3to2[python_targets_python2_7] )"
LIBDEPEND="dev-python/beautifulsoup[${PYTHON_USEDEP}]
	dev-python/mako[${PYTHON_USEDEP}]"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

src_configure() {
	distutils-r1_src_configure
}

src_compile() {
	distutils-r1_src_compile
}

python_install() {
	distutils-r1_python_install \
		--install-scripts="${GAMES_BINDIR}"
}

src_install() {
	distutils-r1_src_install
	prepgamesdirs
}
