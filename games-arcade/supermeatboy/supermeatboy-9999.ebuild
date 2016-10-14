# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# $Id$

EAPI=6

inherit eutils gnome2-utils steam

DESCRIPTION="Platforming with an adorable cube of meat"
HOMEPAGE="http://www.supermeatboy.com https://steamdb.info/app/40809"
#SRC_URI="~amd64 ~x86"
LICENSE="all-rights-reserved"
RESTRICT="bindist"

ESTEAM_APPID=40800

SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="media-libs/libsdl2
	media-libs/openal
	sys-devel/gcc[cxx]"

src_install() {
	exeinto /opt/$PN/bin
	use amd64 && doexe amd64/*
	use x86 && doexe x86/*

	insinto /opt/$PN
	doins -r resources
	doins buttonmap.cfg gameaudio.dat gamedata.dat locdb.txt steam_appid.txt

	doicon -s 64 supermeatboy.png
	make_wrapper $PN /opt/$PN/bin/SuperMeatBoy /opt/$PN
	make_desktop_entry $PN SuperMeatBoy supermeatboy
	dodoc README-linux.txt
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
