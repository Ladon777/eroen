# By eroen <eroen-overlay@occam.eroen.eu>, 2018
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6

inherit eutils

DESCRIPTION="A SPICE circuit optimizer"
HOMEPAGE="https://sourceforge.net/projects/asco"
SRC_URI="mirror://sourceforge/asco/ASCO-$PV.tar.gz"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_compile() {
	emake asco
}

src_install() {
	dobin asco
}
