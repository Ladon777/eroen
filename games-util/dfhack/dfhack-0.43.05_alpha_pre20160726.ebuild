# By eroen, 2012-2016
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6

inherit multilib versionator git-r3 cmake-utils

df_PV=$(get_version_component_range 1-3)

DESCRIPTION="Memory hacking library for Dwarf Fortress and a set of tools that use it"
HOMEPAGE="http://github.com/DFHack/dfhack"
#EGIT_REPO_URI="git://github.com/DFHack/dfhack.git https://github.com/DFHack/dfhack.git"
EGIT_REPO_URI="https://github.com/DFHack/dfhack.git"
if [[ $PV == *.9999 ]]; then
	EGIT_BRANCH="develop"
#elif [[ $PV == *_alpha* ]]; then
#	EGIT_MIN_CLONE="single"
#	EGIT_COMMIT="${PV/_alpha/-alpha}"
else
	EGIT_MIN_CLONE_TYPE=mirror
	EGIT_COMMIT="29963f4b67b9edae74cd69e159bb63730b524d27"
	xml_EGIT_COMMIT="95f0627d9f2fe9179865a1eaebf348ea6afcbc27"
fi

KEYWORDS="-* ~amd64" # ~x86

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
	"
LIBRARY_DEPEND="
	sys-libs/zlib[abi_x86_32]
	"
DEPEND="${LIBRARY_DEPEND}
	${HDEPEND}"
RDEPEND="${LIBRARY_DEPEND}
	~games-roguelike/dwarf-fortress-$df_PV[abi_x86_32]"

PATCHES=( "$FILESDIR"/dfhack-$PV )

QA_PREBUILT="opt/dfhack/hack/libruby.so"

pkg_setup() {
	multilib_toolchain_setup x86
}

src_unpack() {
	git-r3_src_unpack
	if [[ -n $xml_EGIT_COMMIT ]]; then
		cd "$S/library/xml" || die
		git checkout "$xml_EGIT_COMMIT" || die
	fi
}

src_prepare() {
	default
	local install="\${HOME}/.dwarf-fortress-${df_PV}_dfhack" exe="./libs_abi_x86_32/Dwarf_Fortress"
	sed -e "s:^install=.*:install=${install}:" \
		-e "s:^exe=.*:exe=\"${exe}\":" \
		"$FILESDIR"/dfhack > "$T"/dfhack || die
	cp "$FILESDIR"/dfhack-run "$T" || die
}

src_configure() {
	local mycmakeargs=(
		-DDFHACK_BUILD_ARCH=32
		-DEXTERNAL_TINYXML=NO
		-DCMAKE_INSTALL_PREFIX=/opt/dfhack
		-DDFHACK_DATA_DESTINATION=/opt/dfhack/hack
		-DDFHACK_LUA_DESTINATION=/opt/dfhack/hack/lua
		-DDFHACK_PLUGIN_DESTINATION=/opt/dfhack/hack/plugins
		-DDFHACK_LIBRARY_DESTINATION=/opt/dfhack/hack
		-DDFHACK_RUBY_DESTINATION=/opt/dfhack/hack/ruby
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
