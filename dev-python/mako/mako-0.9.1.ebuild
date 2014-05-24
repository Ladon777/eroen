# Copyright 1998-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3,3_4} )

inherit distutils-r1

MY_PN=Mako
MY_P=${MY_PN}-${PV}

DESCRIPTION="A Python templating language"
HOMEPAGE="http://www.makotemplates.org/ http://pypi.python.org/pypi/Mako"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE="doc +cache test"
REQUIRED_USE="cache? ( !python_targets_python3_2 !python_targets_python3_3 )"

RDEPEND="cache? ( >=dev-python/beaker-1.1[$(python_gen_usedep python2\*)] )
	>=dev-python/markupsafe-0.9.2[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/nose[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MY_P}"

python_test() {
	cp -r -l test "${BUILD_DIR}"/ || die

	cd "${BUILD_DIR}"/test || die
	nosetests || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	rm -rf doc/build

	use doc && local HTML_DOCS=( doc/. )
	distutils-r1_python_install_all
}