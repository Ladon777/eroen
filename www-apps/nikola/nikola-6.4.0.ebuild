# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
# >=2.7 >=3.3
# PyRSS2Gen, assets -3.3
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="A static website and blog generator"
HOMEPAGE="http://getnikola.com/"
MY_PN="Nikola"

if [[ ${PV} == *9999* ]]; then
	inherit git-3
	EGIT_REPO_URI="git://github.com/getnikola/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${P}.tar.gz"
	KEYWORDS=""
fi

# Apache-2.0: bootstrap.{css,js}
# CC-BY-NC-SA-2.5: conf.py.in
# !!!: a-study-in-scarlet.txt
LICENSE="MIT-with-advertising Apache-2.0 CC-BY-NC-SA-2.5"
SLOT="0"
IUSE="assets charts jinja markdown minimal"

# needs rst2man to build manpage
# TODO: test if setuptools needed at runtime
DEPEND="dev-python/docutils
	dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="app-arch/gzip
	dev-python/blinker[${PYTHON_USEDEP}]
	python_targets_python2_7? ( >=dev-python/configparser-3.2.0[python_targets_python2_7] )
	dev-python/docutils[${PYTHON_USEDEP}]
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
### test:
# dev-python/coverage
# dev-python/freezegun # not in gentoo
# >=dev-python/mock-1.0.0
# dev-python/nose
# dev-python/python-coveralls # not in gentoo
# pip?

DOCS=( AUTHORS.txt CHANGES.txt CONTRIBUTING.rst README.rst )

optfeature() {
	local desc=$1
	shift
	while (( $# )); do
		if has_version "$1"; then
			elog "  [I] $1 for ${desc}"
		else
			elog "  [ ] $1 for ${desc}"
		fi
		 shift
	done
}

src_install() {
	distutils-r1_src_install

	# hackish way to remove docs that ended up in the wrong place
	rm -rf "${D}"/usr/share/doc/${PN}

	dodoc docs/*.txt
}

pkg_postinst() {
	elog "For additional features, a number of optional runtime dependencies may be"
	elog "installed. Note that many dependencies need to be installed for the python"
	elog "interpreter you are using, or their functionality will not be available."

#	optfeature "Compile BBCode into html" dev-python/bbcode # not in gentoo
	optfeature "Colorized log messages" dev-python/colorama
	optfeature "Compile IPython notebooks into HTML" ">=dev-python/ipython-1.0.0"
#	optfeature "Support for Jinja2 templates" ">=dev-python/jinja-2.7" # currently use flag
#	optfeature "Automatically rebuild site on file changes" >=dev-python/python-livereload-2.1.0 # not in gentoo
#	optfeature "Compile Markdown into HTML" dev-python/markdown # currently use flag
#	optfeature "Embed media from many websites" dev-python/micawber # not in gentoo
#	optfeature "Download files while importing WordPress dumps" dev-python/phpserialize ">=dev-python/requests-1.0" # not in gentoo
#	optfeature "Produce SVG charts for embedding" dev-python/pygal # currently use flag
	optfeature "Hyphenation" dev-python/pyphen
#	optfeature "Enhanced date format parsing" dev-python/python-dateutil # currently use flag
#	optfeature "Install plugins and themes" ">=dev-python/requests-1.0" # currently use flag
#	optfeature "Embed media from Vimeo" ">=dev-python/requests-1.0" # currently use flag
#	optfeature "Inline source code from GIST" ">=dev-python/requests-1.0" # currently use flag
#	optfeature "Yield typographically-improved HTML" ">=dev-python/typogrify-2.0.4" # not in gentoo
#	optfeature "Make bundles of theme CSS and js" dev-python/assets # currently use flag # no python3_3 support

### Not mentioned in requirements*.txt:
	optfeature "Import Atom/RSS feeds and Blogger dumps" dev-python/feedparser
#	optfeature "Remove unused and redundant CSS" dev-python/mincss # not in gentoo
	optfeature "Feed aggregation" dev-python/peewee # no python3_3 support
#	optfeature "Render galleries" ">=virtual/python-imaging-2" # not optional
	optfeature "Compile asciidoc documents into HTML" app-text/asciidoc # executable
	optfeature "Compile Textile into HTML" app-text/pytextile # old python eclass
#	optfeature "Compile reStructuredText into HTML" dev-python/docutils # not optional
	optfeature "Compile misaka markdown documents to HTML" dev-python/misaka # no python3_3 support
	optfeature "Compile txt2tags documents to HTML" app-text/txt2tags # old python eclas
#	optfeature "Compile CreoleWiki to HTML" dev-python/creole # not in gentoo
	optfeature "Compile various documents into HTML" app-text/pandoc # executable
	optfeature "Tidy up HTML" app-text/htmltidy # executable
#	optfeature "Compress CSS and js" app-text/yuicompressor # executable # not in gentoo
	optfeature "Optimize PNG images" media-gfx/optipng # executable
	optfeature "Optimize JPEG images" media-gfx/jpegoptim # executable
#	optfeature "Generate CSS out of LESS sources" www-apps/less # executable lessc # not in gentoo, bundled in ipython, meteor
	optfeature "Build CSS out of Sass sources" dev-ruby/sass # executable
}
