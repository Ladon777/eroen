# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit games versionator git-2 multilib cmake-utils

if [[ ${PV} == "9999" ]]; then
	MY_PV="0.34.11-r2"
else
	MY_PV="$(replace_version_separator 3 '-r')"
fi
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Memory hacking library for Dwarf Fortress and a set of tools that
use it"
HOMEPAGE="https://github.com/peterix/dfhack"
EGIT_HAS_SUBMODULES="yes"
EGIT_REPO_URI="git://github.com/peterix/dfhack.git"
if [[ ! ${PV} == "9999" ]]; then
	EGIT_COMMIT="${MY_PV}"
fi
EGIT_REPO_URI="/home/eroen/dfhack-repo/dfhack"

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
	#games-simulation/dwarffortress[egg=]

src_prepare() {
	multilib_toolchain_setup x86

	local datadir="${GAMES_DATADIR}/${P}"
	local dfhack_libdir="${datadir}/lib32"

	if [[ ! "${PV}" == "9999" ]]; then
		#epatch "${FILESDIR}/dfhack-${MY_PV}/*.patch"
		epatch "${FILESDIR}/dfhack-${MY_PV}"
	fi
	cd "${S}/depends/clsocket"
	epatch "${FILESDIR}/clsocket/0001-build-library-with-pic.patch"
	cd "${S}"
	if use ssense; then
		cd "${S}/plugins/stonesense"
		epatch "${FILESDIR}/ssense/*.patch"
		cd "${S}"
	fi

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
		sed -i "s:libs/Dwarf_Fortress:Dwarf_Fortress:" plugins/Dfusion/luafiles/common.lua
	fi

	if use egg; then
	sed -f - -i ./library/Hooks-egg.cpp <<- EOF || die
		s/SDL_Event\* event/SDL::Event\* event/
		EOF
	fi

	##Issues:
	# - /plugins/df2mc/source/df2minecraft.cpp # Also abandoned
	# - custom raws (with diffs). Make a message.
	# - Due to dwarffortress' special needs wrt. working directory,
	# specifying relative file paths to dfhack plugins will give sub-optimal
	# results. Message.
	# - dfusion is strange. It's always been that, though.
	# - prebuilt ruby
	# - prebuilt allegro for stonesense.
	# - ssense fails when reloaded, does not in old setup. Well, sometimes it
	# does. I don't know anymore. I'll ignore it for now.
	# - stonesense conf file: /usr/share/games/dfhack-9999/stonesense/init.txt
	# Set in ./Config.cpp, installed together with the rest of the directory.
	# - egg
	# - output files
	# - - Make symlinks to (unversioned) /var
	#
	#Ssense functions that fopen filenames:
	#-DumpMaterialNamesToDisk - No users
	#-DumpItemNamesToDisk - 1 user, called on start
	#-DumpPrefessionNamesToDisk - No users
}

src_configure() {
	MY_DOCDIR="/usr/share/doc/${P}"
	mycmakeargs=(
		"-DCMAKE_INSTALL_PREFIX=${GAMES_DATADIR}"
		"-DDFHACK_BINARY_DESTINATION=${GAMES_BINDIR}"
		#"-DDFHACK_LIBRARY_DESTINATION=$(games_get_libdir)"
		# We install interesting libs, let's not infect the rest of the system.
		"-DDFHACK_LIBRARY_DESTINATION=${GAMES_DATADIR}/${P}/lib32"
		"-DDFHACK_EGGY_DESTINATION=$(games_get_libdir)"
		"-DDFHACK_DATA_DESTINATION=${GAMES_DATADIR}/${P}"
		"-DDFHACK_PLUGIN_DESTINATION=${GAMES_DATADIR}/${P}/plugins"
		"-DDFHACK_LUA_DESTINATION=${GAMES_DATADIR}/${P}/lua"
		"-DDFHACK_INCLUDES_DESTINATION=/usr/games/include" # Will break slotting
		"-DDFHACK_DEVLIB_DESTINATION=${GAMES_DATADIR}/${P}/devlib"
		"-DDFHACK_USERDOC_DESTINATION=${MY_DOCDIR}"
		"-DDFHACK_DEVDOC_DESTINATION=${MY_DOCDIR}/dev"
		"-DBUILD_LIBRARY=ON"
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
		mycmakeargs+=(
			"-DBUILD_DEV_PLUGINS=OFF"
			"-DBUILD_SUPPORTED=OFF"
			"-DBUILD_DWARFEXPORT=OFF"
			"-DBUILD_MAPEXPORT=OFF"
			)
	else
		mycmakeargs+=(
			"-DBUILD_DEV_PLUGINS=ON"
			"-DBUILD_SUPPORTED=ON"
			"-DBUILD_DWARFEXPORT=ON"
			"-DBUILD_MAPEXPORT=ON"
			)
	fi

	cmake-utils_src_configure
}

QA_PREBUILT+="${GAMES_DATADIR#/}/${P}/lib32/libruby.so"
