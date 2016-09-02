# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# $Id$

EAPI=6

DESCRIPTION="Data files for Morrowind Official Add-Ons"
HOMEPAGE="http://www.elderscrolls.com http://www.uesp.net/wiki/Morrowind:Official_Add-Ons"
SRC_URI="http://download.zenimax.com/elderscrolls/morrowind/other/entertainers.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/bittercoastsounds.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/area_effect_arrows.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/ebartifact.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/masterindex.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/lefemmarmor1.1.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/adamantiumarmor.zip
	http://download.zenimax.com/elderscrolls/morrowind/other/firemoth1.1.zip"
LICENSE="all-rights-reserved Morrowind-EULA"
RESTRICT="bindist mirror"
S=$WORKDIR

SLOT="0"
KEYWORDS="" # -* ~amd64 ~x86
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

src_install() {
	insinto /usr/share/morrowind-data
	doins -r *.esp Icons Meshes Sound Textures
	doins -r "Data Files/"*.esp "Data Files/Meshes" "Data Files/Textures"

	dodoc readme*.txt "Data Files/"readme*.txt
}

pkg_postinst() {
	elog "If you do not use openmw-launcher, you should add"
	elog "  --content AreaEffectArrows.esp --content EBQ_Artifact.esp --content LeFemmArmor.esp --content adamantiumarmor.esp --content bcsounds.esp --content entertainers.esp --content master_index.esp --content Siege\ at\ Firemoth.esp"
	elog "to your openmw command to load the files from this package."
}
