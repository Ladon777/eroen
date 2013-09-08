# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit linux-info

DESCRIPTION="Show progress of open files and file systems."
HOMEPAGE="https://code.google.com/p/ftop/"
SRC_URI="https://${PN}.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=">=sys-devel/autoconf-2.61"
LIBDEPEND="sys-libs/ncurses"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

pkg_pretend() {
	if ! kernel_is -ge 2 6 22; then
		ewarn "${P} will have limited functionality when not running on" \
			"linux later than 2.6.22."
	fi
}
