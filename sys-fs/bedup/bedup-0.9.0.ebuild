# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT="python2_7" # For cffi

inherit eutils distutils-r1

DESCRIPTION="Btrfs deduplication"
HOMEPAGE="http://pypi.python.org/pypi/bedup"
SRC_URI="https://pypi.python.org/packages/source/b/bedup/bedup-0.9.0.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND="dev-python/cffi
	sys-fs/btrfs-progs
	dev-python/alembic
	dev-python/contextlib2
	dev-python/pyxdg
	dev-python/sqlalchemy
	"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"
