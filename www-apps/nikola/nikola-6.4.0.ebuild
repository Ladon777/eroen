# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
# >=2.7 >=3.3
# PyRSS2Gen -3.3
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="A static website and blog generator"
HOMEPAGE="http://getnikola.com/"
MY_PN="Nikola"

if [[ ${PV} == *9999* ]]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/getnikola/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${P}.tar.gz"
	KEYWORDS=""
fi

LICENSE="MIT-with-advertising"
SLOT="0"
IUSE="assets charts jinja markdown minimal"

# needs rst2man to build manpage
# TODO: test if setuptools needed at runtime
DEPEND="dev-python/docutils[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	python_targets_python2_7? ( >=dev-python/configparser-3.2.0[python_targets_python2_7] )
	dev-python/blinker[${PYTHON_USEDEP}]
	dev-python/colorama[${PYTHON_USEDEP}]
	>=dev-python/doit-0.23.0[${PYTHON_USEDEP}]
	dev-python/logbook[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	>=dev-python/mako-0.6[${PYTHON_USEDEP}]
	dev-python/pygments[${PYTHON_USEDEP}]
	dev-python/PyRSS2Gen[${PYTHON_USEDEP}]
	>=dev-python/pytz-2013d[${PYTHON_USEDEP}]
	dev-python/unidecode[${PYTHON_USEDEP}]
	>=dev-python/yapsy-1.10.2[${PYTHON_USEDEP}]
	>=virtual/python-imaging-2[${PYTHON_USEDEP}]
	assets? ( dev-python/assets[${PYTHON_USEDEP}] )
	charts? ( dev-python/pygal[${PYTHON_USEDEP}] )
	jinja? ( >=dev-python/jinja-2.7[${PYTHON_USEDEP}] )
	markdown? ( dev-python/markdown[${PYTHON_USEDEP}] )
	!minimal? ( dev-python/python-dateutil[${PYTHON_USEDEP}]
		>=dev-python/requests-1.0[${PYTHON_USEDEP}] )"
### optional:
# dev-python/bbcode # not in gentoo
# dev-python/colorama # 6.4.0
# >=dev-python/ipython-1.0.0
# >=dev-python/jinja-2.7 # XXX
# >=dev-python/livereload-2.1.0
# dev-python/markdown # XXX
# dev-python/micawber # not in gentoo
# dev-python/phpserialize # not in gentoo
# dev-python/pygal # XXX
# dev-python/pyphen
# dev-python/python-dateutil # XXX
# >=dev-python/requests-1.0 # XXX NOQA
# >=dev-python/typogrify-2.0.4 # not in gentoo
# dev-python/assets # XXX # -33
### test:
# dev-python/coverage
# dev-python/freezegun # not in gentoo
# >=dev-python/mock-1.0.0
# dev-python/nose
# dev-python/python-coveralls # not in gentoo

DOCS=( AUTHORS.txt CHANGES.txt CONTRIBUTING.rst README.rst )

src_install() {
	distutils-r1_src_install

	# hackish way to remove docs that ended up in the wrong place
	rm -rf "${D}"/usr/share/doc/${PN}

	dodoc docs/*.txt
}
