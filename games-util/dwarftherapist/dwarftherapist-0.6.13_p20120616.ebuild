# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit games qt4-r2 mercurial

MY_PN="DwarfTherapist"
MY_P="${MY_PN}-${PV}"

S="${WORKDIR}/${MY_P}"

DESCRIPTION="Management tool designed to run side-by-side with games-simulation/dwarffortress"
HOMEPAGE="https://code.google.com/p/dwarftherapist/"
EHG_REPO_URI="https://code.google.com/p/dwarftherapist/"
EHG_REVISION="27c3f5c81171531434ab3ca370071068a207022b"

LICENSE="MIT LGPL-2.1-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

COMMON_DEPEND="dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtscript
	"
DEPEND="${COMMON_DEPEND}
	"
RDEPEND="${COMMON_DEPEND}
	"

src_unpack() {
	mercurial_src_unpack
	qt4-r2_src_unpack
}

src_prepare() {
	#Change paths to reflect games policy. The project file controls
	#installation targets, the wrapper script needs to find the binary.
	#Remove the broken doc installation commands
	sed -f - -i dwarftherapist.pro dist/dwarftherapist <<-EOF || die
		s:/usr/share/dwarftherapist:"${GAMES_DATADIR}/${PN}":
		s:/usr/bin:"${GAMES_PREFIX}/bin":
		/^.*doc.extra = .*$/d
		EOF
	#Encoding is deprecated, Version should refer to Desktop Entry Specification
	#version, not application version. The GTK category should accompany the
	#GNOME category.
	sed -f - -i dist/dwarftherapist.desktop <<-EOF || die
		s/GNOME;/GTK;GNOME;/
		/^Version=/d
		/^Encoding=/d
		EOF

	qt4-r2_src_prepare
}

src_install() {
	qt4-r2_src_install

	dodoc "README.txt" "CHANGELOG.txt" "KNOWN_ISSUES.txt"
	dohtml "doc/"*".html"
	dodoc -r "img/screenshots"
	docompress -x "/usr/share/doc/${P}/screenshots/"

	dodir "${GAMES_DATADIR}/${PN}/log/"
	prepgamesdirs
	fperms g+w "${GAMES_DATADIR}/${PN}/log/"
}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "To start Dwarf Therapist, please run 'dwarftherapist'."
	elog
	elog "Your preferences will be kept in"
	elog "'~/.config/UDP Software/Dwarf Therapist.ini'"
	elog
	elog "This snapshot of dwarftherapist contains memory mappings for"
	elog "games-simulation/dwarffortress-34.11 and earlier."
}
