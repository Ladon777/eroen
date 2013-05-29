# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils git-2

DESCRIPTION="A keyboard-centric VTE-based terminal"
HOMEPAGE="https://github.com/thestinger/termite"
EGIT_HAS_SUBMODULES=yes
EGIT_REPO_URI="git://github.com/thestinger/termite.git"
#SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE=""

HDEPEND=""
LIBDEPEND=">=x11-libs/vte-0.34[termite-patch]"
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

src_prepare() {
	sed -i 's/-O3//g' Makefile
}
