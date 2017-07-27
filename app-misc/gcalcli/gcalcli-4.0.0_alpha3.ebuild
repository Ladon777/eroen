# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
# google-api-python-client only supports these
PYTHON_COMPAT=( python2_7 python3_4 python3_5 python3_6 )

inherit distutils-r1

DESCRIPTION="Google Calendar Command Line Interface"
HOMEPAGE="https://github.com/insanum/gcalcli"
SRC_URI="https://github.com/insanum/gcalcli/archive/v${PV/_alpha/a}.tar.gz -> ${P}.tar.gz"
S=$WORKDIR/$PN-${PV/_alpha/a}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	>=dev-python/google-api-python-client-1.4[${PYTHON_USEDEP}]
	dev-python/httplib2[${PYTHON_USEDEP}]
	dev-python/oauth2client[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/vobject[${PYTHON_USEDEP}]
	dev-python/parsedatetime[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
# vobject parsedatetime are optional

DOCS=(ChangeLog README.md docs/)
