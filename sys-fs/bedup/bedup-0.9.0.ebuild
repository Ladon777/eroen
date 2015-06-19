# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_2 )
# 3_3: alembic

inherit eutils distutils-r1

DESCRIPTION="Btrfs deduplication"
HOMEPAGE="http://pypi.python.org/pypi/bedup"
SRC_URI="https://pypi.python.org/packages/source/b/bedup/bedup-0.9.0.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

HDEPEND=""
LIBDEPEND="${PYTHON_DEPS}
	dev-python/cffi[${PYTHON_USEDEP}]
	sys-fs/btrfs-progs
	dev-python/alembic[${PYTHON_USEDEP}]
	dev-python/contextlib2[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/sqlalchemy[sqlite,${PYTHON_USEDEP}]
	"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
