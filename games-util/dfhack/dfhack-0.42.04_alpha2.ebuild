# By eroen, 2012-2016
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5

# games.eclass only used for compatibility with dwarffortress install paths
inherit base games eutils multilib git-r3 cmake-utils

my_PV="${PV/_/-}" # _alphaN -> -alphaN

DESCRIPTION="Memory hacking library for Dwarf Fortress and a set of tools that use it"
HOMEPAGE="http://github.com/DFHack/dfhack"
EGIT_REPO_URI="git://github.com/DFHack/dfhack.git"
#EGIT_BRANCH=
EGIT_COMMIT=${my_PV}

# There is no 32-bit ruby in gentoo yet
SRC_URI="http://cloud.github.com/downloads/jjyg/dfhack/libruby187.tar.gz"

KEYWORDS="-* ~amd64" # ~x86

CMAKE_MIN_VERSION=2.8.9
CMAKE_REMOVE_MODULES_LIST="FindCurses FindDoxygen CMakeVS10FindMake"

LICENSE="ZLIB MIT BSD-2"
SLOT=${PV%%_*} # drop _suffixN
IUSE="api dfusion doc egg isoworld minimal stonesense"

HDEPEND="
	>=sys-devel/gcc-4.5[multilib]
	dev-perl/XML-LibXML
	dev-perl/XML-LibXSLT
	doc? ( app-doc/doxygen )
	"
LIBRARY_DEPEND="
	sys-libs/zlib[abi_x86_32]
	stonesense? ( media-libs/fontconfig[abi_x86_32]
		app-emulation/emul-linux-x86-baselibs[development]
		media-libs/freetype[abi_x86_32]
		x11-libs/libICE[abi_x86_32]
		x11-libs/libSM[abi_x86_32]
		x11-libs/libX11[abi_x86_32]
		x11-libs/libXcursor[abi_x86_32]
		x11-libs/libXext[abi_x86_32]
		x11-libs/libXinerama[abi_x86_32]
		x11-libs/libXrandr[abi_x86_32]
		)
	"
DEPEND="${LIBRARY_DEPEND}
	${HDEPEND}"
RDEPEND="${LIBRARY_DEPEND}
	stonesense? ( app-emulation/emul-linux-x86-opengl
		app-emulation/emul-linux-x86-xlibs
		)
	"
# Circular dependency when building egg.
PDEPEND="games-simulation/dwarffortress:$SLOT"

## missing multilib
#dev-lang/lua - binary bundled
#dev-libs/protobuf - bundled

pkg_setup() {
	multilib_toolchain_setup x86

	df_executable="dwarffortress-${SLOT}"
	dfhack_datadir="${GAMES_DATADIR}/${P}"
	dfhack_docdir="/usr/share/doc/${P}"
	dfhack_statedir="${GAMES_STATEDIR}/${P}"

	dfhack_libdir="$GAMES_PREFIX_OPT/dwarffortress-${SLOT}/libs"

	QA_FLAGS_IGNORED=("${dfhack_libdir#/}"/libruby.so)
	QA_PRESTRIPPED=("${dfhack_libdir#/}"/libruby.so)
	QA_SONAME_NO_SYMLINK=("${dfhack_libdir#/}"/libruby.so)
}

src_unpack() {
	git-r3_src_unpack

	# prebuilt 32-bit libruby:
	unpack ${A}
	mv "${WORKDIR}"/libruby1.8.so.1.8.7 "${WORKDIR}"/libruby.so || die
}

src_prepare() {
	epatch "${FILESDIR}"/${P}/*.patch

#	pushd "${S}"/depends/clsocket
#	epatch "${FILESDIR}"/clsocket/0001-Compile-static-library-as-PIC.patch
#	popd

	#if use stonesense; then
	#	pushd "${S}"/plugins/stonesense
	#	epatch "${FILESDIR}"/stonesense-${PV}/01-null-isn-t-an-int32.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/02-configurable-install-paths.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/03-don-t-segfault-if-logfile-is.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/04-compile-time-configuration-of.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/05-compile-time-configurable-log.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/06-fix-b0rked-xml-file.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/07-compile-time-configurable-dump.patch
	#	epatch "${FILESDIR}"/stonesense-${PV}/08-compile-time-configurable.patch
	#	# Patches that no longer fit upstream, not updated yet.
	#	#epatch "${FILESDIR}"/stonesense/0003-screenshots-in-home-dir.patch
	#	popd
	#fi
	#if use isoworld; then
	#	pushd "${S}"/plugins/isoworld
	#	epatch "${FILESDIR}"/isoworld-${PV}/01-missing-include-dir.patch
	#	popd
	#	ewarn "The isoworld plugin requires agui, and will probably fail to build"
	#fi

	# Fix other scripts
#	if use dfusion; then
#	sed -f - -i plugins/Dfusion/luafiles/{init.lua,friendship/{init.lua,plugin.lua,install.lua},triggers/{plugin.lua,functions_menu.lua},friendship_civ/init.lua,common.lua,embark/{init.lua,plugin.lua},migrants/{init.lua,plugin.lua},xml_struct.lua,xml_types.lua} <<- EOF || die
#		s:("dfusion/:("${datadir}/dfusion/:
#		s:('dfusion/:('${datadir}/dfusion/:
#		EOF
#		sed -i "s:libs/Dwarf_Fortress:Dwarf_Fortress:" plugins/Dfusion/luafiles/common.lua
#	fi

	##Issues:
	# - dfusion is strange. It's always been that, though.
	# - prebuilt ruby
	# - bundled lua
	# - isoworld requires agui
	# - prebuilt allegro for stonesense.
	# - stonesense conf file: /usr/share/games/dfhack-9999/stonesense/init.txt
	# Set in ./Config.cpp, installed together with the rest of the directory.
	# - output files
	# - - Make symlinks to (unversioned) /var
}

src_configure() {
	local mycmakeargs=(
		"$(cmake-utils_use_build api DEVEL)"
		"$(cmake-utils_use_build !minimal DEV_PLUGINS)"
		"$(cmake-utils_use_build dfusion DFUSION)"
		"$(cmake-utils_use_build doc DOCS)"
		"$(cmake-utils_use_build doc DOXYGEN)"
		"$(cmake-utils_use_build !minimal DWARFEXPORT)"
		"$(cmake-utils_use_build egg EGGY)"
		"$(cmake-utils_use_build isoworld ISOWORLD)"
		"-DBUILD_LIBRARY=ON"
		"$(cmake-utils_use_build !minimal MAPEXPORT)"
		"-DBUILD_PLUGINS=ON"
		"-DBUILD_RUBY=ON"
		"-DBUILD_SKELETON=OFF"
		"$(cmake-utils_use_build stonesense STONESENSE)"
		"$(cmake-utils_use_build !minimal SUPPORTED)"
		"-DCMAKE_INSTALL_PREFIX=${GAMES_DATADIR}"
		"-DCONSOLE_NO_CATCH=OFF"
		"-DDFHACK_BINARY_DESTINATION=/usr/bin"
		"-DDFHACK_DATA_DESTINATION=${dfhack_datadir}"
		"-DDFHACK_DEVDOC_DESTINATION=${dfhack_docdir}/dev"
		"-DDFHACK_EGGY_DESTINATION=${dfhack_libdir}"
		"-DDFHACK_INCLUDES_DESTINATION=${GAMES_PREFIX}/include"
		"-DDFHACK_LIBRARY_DESTINATION=${dfhack_libdir}"
		"-DDFHACK_LUA_DESTINATION=${dfhack_datadir}/lua"
		"-DDFHACK_PLUGIN_DESTINATION=${dfhack_datadir}/plugins"
		"-DDFHACK_RUBY_DESTINATION=${dfhack_datadir}/ruby"
		"-DDFHACK_STATEDIR=${GAMES_STATEDIR}/${P}"
		"-DDFHACK_USERDOC_DESTINATION=${dfhack_docdir}"
		"-DDF_EXECUTABLE=${df_executable}"
		)

	cmake-utils_src_configure
}

DOCS=""
src_install() {
	cmake-utils_src_install
	mv "${ED%/}"/usr/bin/dfhack{,-${SLOT}} || die
	mv "${ED%/}"/usr/bin/dfhack-run{,-${SLOT}} || die
	! use egg || mv "${ED%/}"/usr/bin/egghack{,-${SLOT}} || die
	rm -f "${ED%/}/${dfhack_docdir}"/LICENSE.rst || die
	dodir "${dfhack_statedir}"
	if use stonesense; then
		dodir "${GAMES_SYSCONFDIR#/}/${P}/stonesense"
		mv "${ED%/}/${dfhack_datadir#/}/stonesense/init.txt" \
			"${ED%/}/${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt" || die
		dosym "${ROOT}${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt" \
			"${dfhack_datadir#/}/stonesense/init.txt"
		elog
		elog "The Stonesense configuration file can be found at"
		elog "${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt"
	fi

	fperms g+w "${dfhack_statedir}"
	# userpriv: portage user needs to be able to link:
#	fperms o+rx "${dfhack_libdir}"
	use egg && fperms o+rx "${dfhack_libdir}"/libegg.so
}

pkg_postinst() {
	elog "Due to Dwarf Fortress' special needs regarding working directory,"
	elog "specifying relative paths to DFHack plugins can give unintended results."
	elog
	elog "Your dfhack.init should be placed in \${HOME}/.dwarffortress-${SLOT}/ ,"
	elog "otherwise the example configuration will be used."
	elog
	if ! use egg; then
		elog "To start DFHack, please run dfhack-${SLOT}"
	else
		elog "To start DFHack, please run dwarffortress-${SLOT}"
	fi
}
