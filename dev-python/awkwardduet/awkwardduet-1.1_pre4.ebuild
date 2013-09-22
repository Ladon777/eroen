# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT=(python3_2 python3_3)

inherit eutils versionator distutils-r1

MY_PV=${PV/_pre/a}
MY_P=${PN}-${MY_PV}
S="${WORKDIR}"/${MY_P}

DESCRIPTION="Lib3to2 maintenance fork"
HOMEPAGE="https://launchpad.net/awkwardduet"
SRC_URI="https://launchpad.net/${PN}/$(get_version_component_range 1-2)/${MY_PV}/+download/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

HDEPEND="test? ( >=dev-python/nose-1.0.0[${PYTHON_USEDEP}] )"
LIBDEPEND="${PYTHON_DEPS}"
DEPEND="${LIBDEPEND}
	!!dev-python/3to2"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

python_prepare() {
	echo ${EPYTHON}
	if [[ "${EPYTHON}" == python3.2 ]]; then
		# Randomly puts includes in wrong order.
		sed -e '212,223d' -i src/lib3to2/tests/test_imports2.py || die
	fi
}

python_test() {
	esetup.py test
}
