# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# $Id$

EAPI=6

#CHECKREQS_DISK_BUILD="1140M"
inherit steam

DESCRIPTION="Data files for Morrowind"
HOMEPAGE="http://www.elderscrolls.com"
SRC_URI=""
LICENSE="all-rights-reserved Morrowind-EULA"
RESTRICT="bindist mirror"

SLOT="0"
KEYWORDS="" # -* ~amd64 ~x86
IUSE=""

DEPEND=""
RDEPEND=""

STEAM_app_id=22320
STEAM_platform=windows

src_install() {
	insinto /usr/share/morrowind-data
	doins -r "Data Files"
	doins Morrowind.ini Journal.htm
	dodoc Bethesda.TXT readme.txt
}
