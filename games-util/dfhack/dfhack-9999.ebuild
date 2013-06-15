# By eroen, 2012-2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit base eutils versionator multilib git-2 cmake-utils games

if [[ ${PV} == "9999" ]]; then
	MY_PV="0.34.11-r2"
else
	MY_PV="$(replace_version_separator 3 '-r')"
fi
MY_P="${PN}-${MY_PV}"
df_PV="34.11"

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

HDEPEND="
	dev-perl/XML-LibXML
	dev-perl/XML-LibXSLT
	doc? ( app-doc/doxygen )"
LIBRARY_DEPEND="
	app-emulation/emul-linux-x86-baselibs[development]
	ssense? ( media-libs/fontconfig[abi_x86_32]
		media-libs/freetype[abi_x86_32]
		x11-libs/libICE[abi_x86_32]
		x11-libs/libSM[abi_x86_32]
		x11-libs/libX11[abi_x86_32]
		x11-libs/libXcursor[abi_x86_32]
		x11-libs/libXext[abi_x86_32]
		x11-libs/libXinerama[abi_x86_32]
		x11-libs/libXrandr[abi_x86_32] )"
DEPEND="${LIBRARY_DEPEND}
	${HDEPEND}"
RDEPEND="${LIBRARY_DEPEND}
	games-simulation/dwarffortress
	ssense? ( app-emulation/emul-linux-x86-opengl
		app-emulation/emul-linux-x86-xlibs )"

## missing multilib
#dev-lang/lua - binary bundled
#dev-libs/protobuf - bundled
#   sys-libs/zlib (libz.so.1) - baselibs
## ssense
#allegro
#	dev-libs/atk (libatk-1.0.so.0) - gtklibs
#	dev-libs/glib (libgthread-2.0.so.0,libglib-2.0.so.0,libgobject-2.0.so.0,libgmodule-2.0.so.0,libgio-2.0.so.0) - baselibs
#	media-libs/fontconfig (libfontconfig.so.1)
#	media-libs/freetype (libfreetype.so.6)
#	media-libs/jpeg:62 (libjpeg.so.62) - baselibs
#   virtual/glu (libGLU.so.1) - opengl
#	media-libs/libpng:1.2 (libpng12.so.0) - baselibs
#	virtual/opengl (libGL.so.1)
#	sys-libs/zlib (libz.so.1) - baselibs
#	x11-libs/cairo (libcairo.so.2) - gtklibs
#	x11-libs/gdk-pixbuf (libgdk_pixbuf) - gtklibs
#	x11-libs/gtk+ (libgdk-x11-2.0.so.0,libgtk-x11-2.0.so.0) - gtklibs
#	x11-libs/libICE (libICE.so.6)
#	x11-libs/libSM (libSM.so.6)
#	x11-libs/libX11 (libX11.so.6)
#	x11-libs/libXcursor (libXcursor.so.1)
#	x11-libs/libXext (libXext.so.6)
#	x11-libs/libXinerama (libXinerama.so.1)
#	x11-libs/libXrandr (libXrandr.so.2)
#	x11-libs/pango (libpangocairo-1.0.so.0,libpango-1.0.so.0,libpangoft2-1.0.so.0) - gtklibs

multilib_toolchain_setup x86
if use egg; then
	dfhack_libdir="$(games_get_libdir)"
else
	#dfhack_libdir="$(games_get_libdir)/${P}"
	dfhack_libdir="$(games_get_libdir)"
fi

pkg_setup() {
	dfhack_datadir="${GAMES_DATADIR}/${P}"
	dfhack_docdir="/usr/share/doc/${P}"
	dfhack_statedir="${GAMES_STATEDIR}/${P}"
}

src_prepare() {
	epatch "${FILESDIR}"/${P}/01-compile-static-libraries-as.patch
	epatch "${FILESDIR}"/${P}/02-drop-strange-build-options.patch
	epatch "${FILESDIR}"/${P}/03-configurable-install-paths.patch
	epatch "${FILESDIR}"/${P}/04-compile-time-configurable.patch
	epatch "${FILESDIR}"/${P}/05-compile-time-configurable-0.patch
	epatch "${FILESDIR}"/${P}/06-compile-time-configurable-1.patch

	pushd "${S}"/depends/clsocket
	epatch "${FILESDIR}"/clsocket/0001-Compile-static-library-as-PIC.patch
	popd

	if use ssense; then
		pushd "${S}"/plugins/stonesense
		epatch "${FILESDIR}"/stonesense-${PV}/01-null-isn-t-an-int32.patch
		epatch "${FILESDIR}"/stonesense-${PV}/02-configurable-install-paths.patch
		epatch "${FILESDIR}"/stonesense-${PV}/03-don-t-segfault-if-logfile-is.patch
		epatch "${FILESDIR}"/stonesense-${PV}/04-compile-time-configuration-of.patch
		epatch "${FILESDIR}"/stonesense-${PV}/05-compile-time-configurable-log.patch
		epatch "${FILESDIR}"/stonesense-${PV}/06-fix-b0rked-xml-file.patch
		epatch "${FILESDIR}"/stonesense-${PV}/07-compile-time-configurable-dump.patch
		epatch "${FILESDIR}"/stonesense-${PV}/08-compile-time-configurable.patch
		# Patches that no longer fit upstream, not updated yet.
		#epatch "${FILESDIR}"/stonesense/0003-screenshots-in-home-dir.patch
		popd
	fi

	# Fix up the startup scripts
	sed -i "package/linux/dfhack" \
		-e "s%\"\./hack\"%\"${dfhack_libdir}\"%" \
		-e "s%\"\./hack/libs\"%\"${dfhack_libdir}/libs\"%" \
		-e "s%\./hack/libdfhack.so%\"${dfhack_libdir}/libdfhack.so\"%" \
		-e "s%\./libs/Dwarf_Fortress%df-${df_PV}%" \
		|| die "dfhack sed"

	sed -i "package/linux/dfhack-run" \
		-e "s%\"\./hack"%"${dfhack_libdir}\"%" \
		-e "s%\"\./hack/libs"%"${dfhack_libdir/libs}\"%" \
		-e "s%hack/dfhack-run%\"${dfhack_libdir}/dfhack-run\"%" \
		|| die "dfhack-run sed"

	# Fix other scripts
	sed -i "plugins/ruby/ruby.rb" \
		-e "s%\./hack/ruby/%${GAMES_DATADIR}/${P}/ruby/%" \
		|| die "ruby/ruby.rb sed failed"
#	if use dfusion; then
#	sed -f - -i plugins/Dfusion/luafiles/{init.lua,friendship/{init.lua,plugin.lua,install.lua},triggers/{plugin.lua,functions_menu.lua},friendship_civ/init.lua,common.lua,embark/{init.lua,plugin.lua},migrants/{init.lua,plugin.lua},xml_struct.lua,xml_types.lua} <<- EOF || die
#		s:("dfusion/:("${datadir}/dfusion/:
#		s:('dfusion/:('${datadir}/dfusion/:
#		EOF
#		sed -i "s:libs/Dwarf_Fortress:Dwarf_Fortress:" plugins/Dfusion/luafiles/common.lua
#	fi

	#if use egg; then
#	sed -f - -i ./library/Hooks-egg.cpp <<- EOF || die
#		s/SDL_Event\* event/SDL::Event\* event/
#		EOF
	#fi

	##Issues:
	# - libdir should be hidden
	# - egg
	# - df version
	# - dfusion is strange. It's always been that, though.
	# - prebuilt ruby
	# - prebuilt allegro for stonesense.
	# - stonesense conf file: /usr/share/games/dfhack-9999/stonesense/init.txt
	# Set in ./Config.cpp, installed together with the rest of the directory.
	# - output files
	# - - Make symlinks to (unversioned) /var
}

src_configure() {
	mycmakeargs=(
		"$(cmake-utils_use api BUILD_DEVEL)"
		"$(cmake-utils_use dfusion BUILD_DFUSION)"
		"$(cmake-utils_use doc BUILD_DOXYGEN)"
		"$(cmake-utils_use egg BUILD_EGGY)"
		"-DBUILD_ISOWORLD=OFF"
		"-DBUILD_LIBRARY=ON"
		"-DBUILD_PLUGINS=ON"
		"-DBUILD_RUBY=ON"
		"-DBUILD_SKELETON=OFF"
		"$(cmake-utils_use ssense BUILD_STONESENSE)"
		"-DCMAKE_INSTALL_PREFIX=${GAMES_DATADIR}"
		"-DCONSOLE_NO_CATCH=OFF"
		"-DDL_RUBY=ON"

		"-DDFHACK_STATEDIR=${GAMES_STATEDIR}/${P}"
		"-DDFHACK_BINARY_DESTINATION=${GAMES_BINDIR}"
		"-DDFHACK_LIBRARY_DESTINATION=${dfhack_libdir}"
		"-DDFHACK_EGGY_DESTINATION=${dfhack_libdir}"
		"-DDFHACK_DATA_DESTINATION=${dfhack_datadir}"
		"-DDFHACK_PLUGIN_DESTINATION=${dfhack_datadir}/plugins"
		"-DDFHACK_LUA_DESTINATION=${dfhack_datadir}/lua"
		"-DDFHACK_RUBY_DESTINATION=${dfhack_datadir}/ruby"
		"-DDFHACK_INCLUDES_DESTINATION=/usr/games/include"
		"-DDFHACK_DEVLIB_DESTINATION=${dfhack_datadir}/devlib"
		"-DDFHACK_USERDOC_DESTINATION=${dfhack_docdir}"
		"-DDFHACK_DEVDOC_DESTINATION=${dfhack_docdir}/dev"
		"-DSSENSE_ALLEGRO_DESTINATION=${dfhack_libdir}"
		"-DSSENSE_RES_DESTINATION=${dfhack_datadir}/stonesense"
		"-DSSENSE_DOC_DESTINATION=${dfhack_docdir}/stonesense"
		)
	if use minimal; then
		mycmakeargs+=(
			"-DBUILD_DEV_PLUGINS=OFF"
			"-DBUILD_DWARFEXPORT=OFF"
			"-DBUILD_MAPEXPORT=OFF"
			"-DBUILD_SUPPORTED=OFF"
			)
	else
		mycmakeargs+=(
			"-DBUILD_DEV_PLUGINS=ON"
			"-DBUILD_DWARFEXPORT=ON"
			"-DBUILD_MAPEXPORT=ON"
			"-DBUILD_SUPPORTED=ON"
			)
	fi

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

QA_PREBUILT+="${dfhack_libdir}"/libruby.so

src_install() {
	cmake-utils_src_install
	mv "${D}/${GAMES_BINDIR}/dfhack" \
		"${D}/${GAMES_BINDIR}/dfhack-${PV}" || die
	mv "${D}/${GAMES_BINDIR}/dfhack-run" \
		"${D}/${GAMES_BINDIR}/dfhack-run-${PV}" || die
	dodir "${dfhack_statedir}"
	if use ssense; then
		dodir "${GAMES_SYSCONFDIR#/}/${P}/stonesense"
		mv "${D}/${dfhack_datadir#/}/stonesense/init.txt" \
			"${D}/${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt" || die
		dosym "${ROOT}${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt" \
			"${dfhack_datadir#/}/stonesense/init.txt"
		elog
		elog "The Stonesense configuration file can be found at"
		elog "${GAMES_SYSCONFDIR#/}/${P}/stonesense/init.txt"
	fi
	prepgamesdirs
	fperms g+w "${dfhack_statedir}" || die
	# portage user needs to be able to link:
	( ! use egg || fperms o+rx "$(games_get_libdir)"/libegg.so ) || die
}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "Due to Dwarf Fortress' special needs regarding working directory,"
	elog "specifying relative paths to DFHack plugins can give unintended"
	elog "results."
	elog
	elog "DFHack installs custom raw files for dwarffortress in"
	elog "${dfhack_datadir}/raw"
	elog "To use them, copy them into your raw folder and apply the diffs."
	elog
	elog "To start DFHack, please run dfhack-${PV}"
}
