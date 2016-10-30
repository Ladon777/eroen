# By eroen <eroen-overlay@occam.eroen.eu>, 2013 - 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6
PYTHON_COMPAT=(python{3_4,3_5})

inherit eutils versionator distutils-r1

MY_PV=${PV/_pre/a}
MY_P=${PN}-${MY_PV}
S="${WORKDIR}"/${MY_P}

DESCRIPTION="Lib3to2 maintenance fork"
HOMEPAGE="https://launchpad.net/awkwardduet https://pypi.python.org/pypi/awkwardduet"
SRC_URI="https://launchpad.net/${PN}/$(get_version_component_range 1-2)/${MY_PV}/+download/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

LIBDEPEND="${PYTHON_DEPS}
	dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${LIBDEPEND}
	!!dev-python/3to2
	test? ( >=dev-python/nose-1.0.0[${PYTHON_USEDEP}] )"
RDEPEND="${LIBDEPEND}"

python_prepare() {
	case "${EPYTHON}" in
		python3.4)
			# Randomly puts includes in wrong order.
			sed -e '212,223d' -i src/lib3to2/tests/test_imports2.py || die
			;;
	esac
}

python_test() {
	esetup.py test
}

src_test() {
	eshopts_push -u failglob
	distutils-r1_src_test
	eshopts_pop
}
