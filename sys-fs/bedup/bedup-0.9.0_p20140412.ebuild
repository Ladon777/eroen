# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_3 )
# 3_2: alembic
# 3_4: contextlib, pyxdg

inherit eutils git-r3 distutils-r1

DESCRIPTION="Btrfs deduplication"
HOMEPAGE="http://pypi.python.org/pypi/bedup http://github.com/g2p/bedup/"
#SRC_URI="https://pypi.python.org/packages/source/b/bedup/bedup-0.9.0.tar.gz"
EGIT_REPO_URI="https://github.com/g2p/bedup.git"
EGIT_COMMIT="5189e166145b8954ac41883f81ef3c3b50dc96ab"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test xdg"

# interactive has automagic run-time deps.
LIBDEPEND="
	>=dev-python/cffi-0.4.2[${PYTHON_USEDEP}]
	dev-python/alembic[${PYTHON_USEDEP}]
	dev-python/contextlib2[${PYTHON_USEDEP}]
	>=dev-python/pycparser-2.9.1[${PYTHON_USEDEP}]
	xdg? ( dev-python/pyxdg[${PYTHON_USEDEP}] )
	>=dev-python/sqlalchemy-0.8.2[sqlite,${PYTHON_USEDEP}]
	sys-fs/btrfs-progs
	"
DEPEND="${LIBDEPEND}
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )
	"
RDEPEND="${LIBDEPEND}"

use xdg || PATCHES+=( "${FILESDIR}"/20140412-use-var-db-bedup-for-db-drop-xdg-dependency.patch )

src_test() {
	local testvar=${PN}_RUN_TESTS
	if [[ -z "${!testvar}" ]]; then
		ewarn "Tests are skipped by default, since they fail if any of the"
		ewarn "following portage FEATURES are enabled:"
		ewarn "    sandbox userpriv usersandbox"
		ewarn
		ewarn "If you want to run the tests anyway, set in your environment:"
		ewarn "    ${PN}_RUN_TESTS=yes"
		ewarn
	else
		distutils-r1_src_test
	fi
}

python_test() {
		py.test -s "${BUILD_DIR}"/lib/bedup || die "py.test failed for ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all
	use xdg || dodir /var/db/bedup
}

pkg_postinst() {
	elog "${PN} offers additional features if the following package is installed:"
	optfeature "interactive mode" dev-python/ipdb
}
