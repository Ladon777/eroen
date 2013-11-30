# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_2 python3_3 )
# 3_3: alembic

inherit eutils git-2 distutils-r1

DESCRIPTION="Btrfs deduplication"
HOMEPAGE="http://pypi.python.org/pypi/bedup"
#SRC_URI="https://pypi.python.org/packages/source/b/bedup/bedup-0.9.0.tar.gz"
EGIT_REPO_URI="https://github.com/g2p/bedup.git"
EGIT_COMMIT="244cc49b779a81f2dc1bf1df62cbecc53e39d454"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="interactive xdg"

# interactive has automagic run-time deps.
HDEPEND=""
LIBDEPEND="${PYTHON_DEPS}
	>=dev-python/cffi-0.4.2[${PYTHON_USEDEP}]
	dev-python/alembic[${PYTHON_USEDEP}]
	dev-python/contextlib2[${PYTHON_USEDEP}]
	>=dev-python/pycparser-2.9.1[${PYTHON_USEDEP}]
	xdg? ( dev-python/pyxdg[${PYTHON_USEDEP}] )
	dev-python/sqlalchemy[sqlite,${PYTHON_USEDEP}]
	sys-fs/btrfs-progs
	"
DEPEND="${LIBDEPEND}
	interactive? ( dev-python/ipdb[${PYTHON_USEDEP}] )"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

use xdg || PATCHES+=( "${FILESDIR}"/use-var-db-bedup-for-db-drop-xdg-dependency.patch )

src_install() {
	distutils-r1_src_install
	dodir /var/db/bedup
}
