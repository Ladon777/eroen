# By eroen, 2012-2016
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6

inherit versionator multilib git-r3 cmake-utils

df_PV=$(get_version_component_range 1-3)

DESCRIPTION="Memory hacking library for Dwarf Fortress and a set of tools that use it"
HOMEPAGE="http://github.com/DFHack/dfhack"
EGIT_REPO_URI="git://github.com/DFHack/dfhack.git https://github.com/DFHack/dfhack.git"
if [[ $PV == *.9999 ]]; then
	EGIT_BRANCH="develop"
elif [[ $PV == *_alpha* ]]; then
	EGIT_COMMIT="${PV/_alpha/-alpha}"
else
	EGIT_COMMIT="$(replace_version_separator 3 "-r")"
fi

# KEYWORDS="-* ~amd64" # ~x86

CMAKE_MIN_VERSION=2.8.0
CMAKE_REMOVE_MODULES_LIST="FindCurses FindDoxygen CMakeVS10FindMake"

LICENSE="ZLIB MIT BSD-2 BSD CC-BY-SA-3.0"
SLOT="0"
IUSE=""

HDEPEND="
	>=sys-devel/gcc-4.5[multilib]
	dev-lang/perl
	dev-perl/XML-LibXML
	dev-perl/XML-LibXSLT
	dev-vcs/git
	"
LIBRARY_DEPEND="
	sys-libs/zlib[abi_x86_32]
	"
DEPEND="${LIBRARY_DEPEND}
	${HDEPEND}"
RDEPEND="${LIBRARY_DEPEND}
	~games-roguelike/dwarf-fortress-$df_PV"

pkg_setup() {
	multilib_toolchain_setup x86
}

PATCHES=( "$FILESDIR"/dfhack-$PV )
src_prepare() {
	default
	cp "$FILESDIR"/dfhack{,-run} "$T" || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/opt/dfhack
		-DDFHACK_DATA_DESTINATION=/opt/dfhack/hack
		-DDFHACK_LUA_DESTINATION=/opt/dfhack/hack/lua
		-DDFHACK_PLUGIN_DESTINATION=/opt/dfhack/hack/plugins
		-DDFHACK_LIBRARY_DESTINATION=/opt/dfhack/hack
		-DDFHACK_RUBY_DESTINATION=/opt/dfhack/hack/ruby
		-DEXTERNAL_TINYXML=OFF
		)

	cmake-utils_src_configure
}

DOCS=""
src_install() {
	cmake-utils_src_install

	dobin "$T"/dfhack{,-run}
}

pkg_postinst() {
	elog "Due to Dwarf Fortress' special needs regarding working directory,"
	elog "specifying relative paths to DFHack plugins can give unintended results."
	elog
	elog "Your dfhack.init should be placed in \${HOME}/.dwarf-fortress ,"
	elog "otherwise the example configuration will be used."
	elog
	elog "To start DFHack, please run dfhack"
}
