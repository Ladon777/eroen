# By eroen, 2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5

inherit eutils games

DESCRIPTION="Roguelike and city-building in a procedurally generated high fantasy universe."
HOMEPAGE="http://www.bay12games.com/dwarves/"
SRC_URI="http://www.bay12games.com/dwarves/df_${PV//./_}_linux.tar.bz2"

S=${WORKDIR}/df_linux

# DF: allows unmodified redistribution free of charge
# libgraphics: BSD
LICENSE="all-rights-reserved BSD"
SLOT=${PV}
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

LIBGRAPHICS_RDEPEND="
	dev-libs/glib[abi_x86_32]
	virtual/glu[abi_x86_32]
	=media-libs/libsdl-1*[abi_x86_32]
	media-libs/sdl-image[abi_x86_32]
	media-libs/sdl-ttf[abi_x86_32]
	x11-libs/gtk+:2[abi_x86_32]
	"
RDEPEND="
	${LIBGRAPHICS_RDEPEND}
	=media-libs/libsdl-1*[abi_x86_32]
	>=sys-devel/gcc-4.5
	"
DEPEND=""

MY_PREFIX=${GAMES_PREFIX_OPT}/${P}
DF_DIR='${HOME}'/.${P}

QA_PREBUILT="${MY_PREFIX#/}/libs/*"

src_prepare() {
	# libgcc: GLIBC_2.2.4 -> gcc-4.5 ?
	# libstdc++: GLIBCXX_3.4.14 -> gcc-4.5 ?
	rm -f libs/{libgcc_s.so.1,libstdc++.so.6} || die

	cp "${FILESDIR}"/dwarffortress.sh "${T}"/${P}
	sed -e "s:@@DF_DIR@@:${DF_DIR}:" \
		-e "s:@@DATA_PREFIX@@:${MY_PREFIX}:" \
		-e '/PRELOAD_LIBZ/s/false/true/' \
		-i "${T}"/${P} || die

	# For raws.
	epatch_user
}

src_install() {
	dodoc README.linux "command line.txt" "file changes.txt" readme.txt "release notes.txt"
	insinto "${MY_PREFIX}"
	doins -r data/ libs/ raw/
	dogamesbin "${T}"/${P}
	prepgamesdirs
	fperms 755 "${MY_PREFIX}"/libs/Dwarf_Fortress
}

pkg_postinst() {
	elog "The ${P} wrapper script will copy and symlink required"
	elog "files to ${DF_DIR} before launching ${PN}."
	elog "Before making modifications to the symlinked files, replace the links"
	elog "with their targets."
	elog
	ewarn "${PN} versions from 40.03 are unable to import saves from"
	ewarn "versions 40.01 and 40.02."
	ewarn
	games_pkg_postinst
}
