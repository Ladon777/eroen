# By eroen, 2013
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5
PYTHON_COMPAT=(python2_7 python3_3)

if [[ ${PV} == *9999* ]]; then
	inherit git-r3 distutils-r1
	EGIT_REPO_URI="https://www.eroen.eu/cgit/cgit.cgi/ga_wrapper"
else
	inherit distutils-r1
	SRC_URI="${P}.tar.gz"
	KEYWORDS="~x86 ~amd64"
fi

DESCRIPTION="wrapper for using git-annex for distfiles with portage"
HOMEPAGE="https://www.eroen.eu"

LICENSE="ISC"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-vcs/git-annex"
