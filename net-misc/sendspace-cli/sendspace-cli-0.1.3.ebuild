# By eroen <eroen-overlay@occam.eroen.eu>, 2013 - 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6
PYTHON_COMPAT=(python2_7 python3_{4,5})

inherit distutils-r1

DESCRIPTION="For uploading files to SendSpace from command line."
HOMEPAGE="https://github.com/Tatsh/sendspace-cli https://pypi.python.org/pypi/sendspace-cli"
SRC_URI="mirror://pypi/s/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-python/pycurl[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]"
DEPEND=""
