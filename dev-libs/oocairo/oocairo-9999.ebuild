# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit autotools-utils git-2

DESCRIPTION="Lua bindings to the cairo library"
HOMEPAGE="http://oocairo.naquadah.org/"
if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://git.naquadah.org/oocairo.git"
else
	SRC_URI=""
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND="sys-devel/automake:1.11"
LIBDEPEND="dev-lang/lua
	x11-libs/cairo"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

AUTOTOOLS_AUTORECONF=yes
WANT_AUTOMAKE=1.11
