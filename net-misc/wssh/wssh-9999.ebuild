# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT="python2_7"

DESCRIPTION="command-line utility/shell for WebSocket inspired by netcat"
HOMEPAGE="https://github.com/progrium/wssh"

if [[ "${PV}" == *9999 ]]; then
	inherit eutils distutils-r1 git-r3
	EGIT_REPO_URI="http://github.com/progrium/${PN}.git"
	KEYWORDS=""
	VCSDEPEND="dev-vcs/git[curl]"
else
	inherit eutils distutils-r1
	SRC_URI=""
	KEYWORDS="~amd64 ~x86"
	VCSDEPEND=""
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="${VCSDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=">=dev-python/gevent-0.13.6[${PYTHON_USEDEP}]
	>=dev-python/ws4py-0.2.4[${PYTHON_USEDEP}]"

src_prepare() {
	sed -e 's/==/>=/g' -i "${S}"/setup.py || die "setup.py sed failed"
}
