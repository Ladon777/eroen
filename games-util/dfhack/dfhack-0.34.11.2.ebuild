# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit games versionator git-2 multilib cmake-utils

if [[ ! ${PV} == "9999" ]]; then
	MY_PV="$(replace_version_separator 3 '-r')"
	MY_P="${PN}-${MY_PV}"
fi

DESCRIPTION="Memory hacking library for Dwarf Fortress and a set of tools that
use it"
HOMEPAGE="https://github.com/peterix/dfhack"
EGIT_HAS_SUBMODULES="yes"
EGIT_REPO_URI="git://github.com/peterix/dfhack.git"
if [[ ! ${PV} == "9999" ]]; then
	EGIT_COMMIT="${MY_PV}"
fi

CMAKE_REMOVE_MODULES_LIST="FindCurses FindDoxygen CMakeVS10FindMake"

LICENSE="ZLIB MIT BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc api minimal dfusion ssense egg"

COMMON_DEPEND=""
DEPEND="${COMMON_DEPEND}
	dev-vcs/git
	dev-util/cmake
	dev-perl/XML-LibXML
	dev-perl/XML-LibXSLT
	doc? (
		app-doc/doxygen
		)
	"
RDEPEND="${COMMON_DEPEND}
	games-simulation/dwarffortress
	app-emulation/emul-linux-x86-baselibs
	ssense? (
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-opengl
		app-emulation/emul-linux-x86-xlibs
		)
	"
QA_PREBUILT+="${GAMES_DATADIR#/}/${P}/lib32/libruby.so"
# The allegro libs are also prebuilt, but don't break things.

src_prepare() {
	multilib_toolchain_setup x86

	local datadir="${GAMES_DATADIR}/${P}"
	local dfhack_libdir="${datadir}/lib32"

	local EPATCH_FORCE="yes"
	local EPATCH_SUFFIX="patch"
	if [[ ! "${PV}" == "9999" ]]; then
		EPATCH_SOURCE="${FILESDIR}/dfhack-${MY_PV}" epatch
	fi
	if use ssense; then
		cd "${S}/plugins/stonesense"
		EPATCH_SOURCE="${FILESDIR}/ssense" epatch
	fi
	cd "${S}"

	# Fix up the startup scripts
	sed -f - -i "package/linux/dfhack" "package/linux/dfhack-run" <<- EOF || die
		s%"\./stonesense/deplibs"%"${datadir}/stonesense/deplibs"%
		s%"\./hack"%"${dfhack_libdir}"%
		s%\./hack/libdfhack.so%"${dfhack_libdir}/libdfhack.so"%
		s%\./libs/Dwarf_Fortress%"df-34.11"%
		s%hack/dfhack-run%"${dfhack_libdir}/dfhack-run"%
		EOF

	sed -i "s:\./hack/ruby/:${GAMES_DATADIR}/${P}/ruby/:" \
		"./plugins/ruby/ruby.rb" || die
	if use dfusion; then
	sed -f - -i plugins/Dfusion/luafiles/{init.lua,friendship/{init.lua,plugin.lua,install.lua},triggers/{plugin.lua,functions_menu.lua},friendship_civ/init.lua,common.lua,embark/{init.lua,plugin.lua},migrants/{init.lua,plugin.lua},xml_struct.lua,xml_types.lua} <<- EOF || die
		s:("dfusion/:("${datadir}/dfusion/:
		s:('dfusion/:('${datadir}/dfusion/:
		EOF
		sed -i "s:libs/Dwarf_Fortress:Dwarf_Fortress:" \
			"plugins/Dfusion/luafiles/common.lua" || die
	fi

	if use egg; then
	sed -f - -i ./library/Hooks-egg.cpp <<- EOF || die
		s/SDL_Event\* event/SDL::Event\* event/
		EOF
	fi
}

src_configure() {
	local MY_DOCDIR="/usr/share/doc/${P}"
	mycmakeargs=(
		"-DCMAKE_INSTALL_PREFIX=${GAMES_DATADIR}"
		"-DDFHACK_BINARY_DESTINATION=${GAMES_BINDIR}"
		# We install interesting libs, let's not infect the rest of the system.
		"-DDFHACK_LIBRARY_DESTINATION=${GAMES_DATADIR}/${P}/lib32"
		"-DDFHACK_EGGY_DESTINATION=$(games_get_libdir)"
		"-DDFHACK_DATA_DESTINATION=${GAMES_DATADIR}/${P}"
		"-DDFHACK_USERDOC_DESTINATION=${MY_DOCDIR}"
		"-DDFHACK_DEVDOC_DESTINATION=${MY_DOCDIR}/dev"
		"-DDFHACK_STATEDIR=${GAMES_STATEDIR}/${P}"
		"-DBUILD_LIBRARY=ON"
		# Breaks slotting
		"$(cmake-utils_use egg BUILD_EGGY)"
		"-DBUILD_PLUGINS=ON"
		"-DBUILD_RUBY=ON"
		"-DDL_RUBY=ON" # W/o this, libruby.so will be missing => breakage
		"$(cmake-utils_use dfusion BUILD_DFUSION)"
		"$(cmake-utils_use ssense BUILD_STONESENSE)"
		"$(cmake-utils_use doc BUILD_DOXYGEN)"
		# Will break slotting, use flag.
		"$(cmake-utils_use api BUILD_DEVEL)"
		"-DBUILD_SKELETON=OFF"
		"-DCONSOLE_NO_CATCH=OFF"
		)
	if use minimal; then
		mycmakeargs+=( "-DBUILD_DEV_PLUGINS=OFF"
			"-DBUILD_SUPPORTED=OFF"
			"-DBUILD_DWARFEXPORT=OFF"
			"-DBUILD_MAPEXPORT=OFF" )
	else
		mycmakeargs+=( "-DBUILD_DEV_PLUGINS=ON"
			"-DBUILD_SUPPORTED=ON"
			"-DBUILD_DWARFEXPORT=ON"
			"-DBUILD_MAPEXPORT=ON" )
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mv "${D}/${GAMES_BINDIR}/dfhack" "${D}/${GAMES_BINDIR}/dfhack-${PV}" || die
	mv "${D}/${GAMES_BINDIR}/dfhack-run" "${D}/${GAMES_BINDIR}/dfhack-run-${PV}" || die
	dodir "${GAMES_STATEDIR}/${P}"
	if use ssense; then
		dodir "${GAMES_SYSCONFDIR}/${P}/stonesense"
		mv "${D}/${GAMES_DATADIR#/}/${P}/stonesense/init.txt" \
			"${D}/${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt" || die
		dosym "${GAMES_SYSCONFDIR}/${P}/stonesense/init.txt" \
			"${GAMES_DATADIR}/${P}/stonesense/init.txt"
		elog
		elog "The Stonesense configuration file can be found at"
		elog "${GAMES_SYSCONFDIR}/${P}/stonesense/init.txt"
	fi

	prepgamesdirs
	fperms g+w "${GAMES_STATEDIR}/${P}" || die
}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "Due to Dwarf Fortress' special needs regarding working directory,"
	elog "specifying relative paths to DFHack plugins can give unintended"
	elog "results."
	elog
	elog "DFHack installs custom raw files for Dwarf Fortress in"
	elog "${GAMES_DATADIR}/${P}/raw"
	elog "To use them, copy them into your raw folder and apply the diffs."
	elog
	elog "To start DFHack, please run dfhack-${PV}"
}
