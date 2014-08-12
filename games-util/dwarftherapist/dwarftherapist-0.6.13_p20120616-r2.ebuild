# By eroen, 2013-2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5

inherit base qmake-utils mercurial games

S=${WORKDIR}/DwarfTherapist-${PV}

DESCRIPTION="Management tool designed to run side-by-side with games-simulation/dwarffortress"
HOMEPAGE="https://code.google.com/p/dwarftherapist/"
EHG_REPO_URI="https://code.google.com/p/dwarftherapist/"
EHG_REVISION="27c3f5c81171531434ab3ca370071068a207022b"

LICENSE="MIT LGPL-2.1-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND="dev-qt/qtcore"
LIBDEPEND="
	dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtscript
	"
DEPEND="${HDEPEND}
	${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"

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
}

src_configure() {
	eqmake4 dwarftherapist.pro
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	insinto "${GAMES_DATADIR}"/${PN}/etc/memory_layouts/linux
	doins "${FILESDIR}"/v0.40.05.ini
	doins "${FILESDIR}"/v0.40.08.ini

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
	elog "the following dwarffortress versions:"
	elog "   0.28.181.40d16"
	elog "   0.31.[04,05,08,15-25]"
	elog "   0.34.[04-09]"
	elog "   0.40.[05,08]"
}
