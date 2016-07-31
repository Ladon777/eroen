# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit multilib-build toolchain-funcs versionator

MY_PV=$(replace_all_version_separators _ "$(get_version_component_range 2-)")
MY_PN=df
MY_P=${MY_PN}_${MY_PV}

DESCRIPTION="A single-player fantasy game"
HOMEPAGE="http://www.bay12games.com/dwarves"
SRC_URI="abi_x86_64? ( http://www.bay12games.com/dwarves/${MY_P}_linux.tar.bz2 )
	abi_x86_32? ( http://www.bay12games.com/dwarves/${MY_P}_linux32.tar.bz2 )"

LICENSE="free-noncomm BSD BitstreamVera"
SLOT="0"
KEYWORDS="~amd64 ~x86 -*"
IUSE="debug"

RDEPEND="media-libs/glew:0[${MULTILIB_USEDEP}]
	media-libs/libsdl[joystick,video,${MULTILIB_USEDEP}]
	media-libs/sdl-image[png,${MULTILIB_USEDEP}]
	media-libs/sdl-ttf[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	virtual/glu[${MULTILIB_USEDEP}]
	x11-libs/gtk+:2[${MULTILIB_USEDEP}]"
# Yup, libsndfile, openal and ncurses are only needed at compile-time; the code
# dlopens them at runtime if requested.
DEPEND="${RDEPEND}
	media-libs/libsndfile[${MULTILIB_USEDEP}]
	media-libs/openal[${MULTILIB_USEDEP}]
	sys-libs/ncurses[unicode,${MULTILIB_USEDEP}]
	virtual/pkgconfig[${MULTILIB_USEDEP}]"

S=${WORKDIR}

gamesdir="/opt/${PN}"
QA_PREBUILT="${gamesdir#/}/libs/Dwarf_Fortress"
RESTRICT="strip"

src_unpack() {
	abi_src_unpack() {
		case "$MULTILIB_ABI_FLAG" in
			abi_x86_32) local f=${MY_P}_linux32.tar.bz2 ;;
			abi_x86_64) local f=${MY_P}_linux.tar.bz2 ;;
			*) die ;;
		esac
		unpack "$f"
		mv "df_linux" "$BUILD_DIR" || die
	}
	multilib_foreach_abi abi_src_unpack
}

src_prepare() {
	abi_src_prepare() {
		cd "$BUILD_DIR" || die
		rm -f libs/*.so* || die
		sed -i -e '1i#include <cmath>' g_src/ttf_manager.cpp || die
		default_src_prepare
	}
	multilib_foreach_abi abi_src_prepare
}

src_configure() {
	CXXFLAGS+=" -D$(use debug || echo N)DEBUG"
}

src_compile() {
	abi_src_compile() {
		tc-export PKG_CONFIG
		cd "$BUILD_DIR" || die
		emake -f "${FILESDIR}/Makefile.native"

		if multilib_is_native_abi; then
			local install="\${HOME}/.dwarf-fortress-${PV}" exe="./libs/Dwarf_Fortress"
		else
			local install="\${HOME}/.dwarf-fortress-${PV}_${MULTILIB_ABI_FLAG}" exe="./libs_${MULTILIB_ABI_FLAG}/Dwarf_Fortress"
		fi
		sed -e "s:^gamesdir=.*:gamesdir=${gamesdir}:" \
			-e "s:^install=.*:install=\"${install}\":" \
			-e "s:^exe=.*:exe=\"${exe}\":" \
			"${FILESDIR}/dwarf-fortress" > dwarf-fortress || die
	}
	multilib_foreach_abi abi_src_compile
}

src_install() {
	abi_src_install() {
		cd "$BUILD_DIR" || die

		# install data-files and libs
		insinto "${gamesdir}"
		doins -r raw data libs

		# install our wrapper
		if multilib_is_native_abi; then
			dobin dwarf-fortress
		else
			newbin dwarf-fortress "dwarf-fortress_${MULTILIB_ABI_FLAG}"
		fi

		# install docs
		dodoc README.linux *.txt

		fperms 755 "${gamesdir}"/libs/Dwarf_Fortress
		if ! multilib_is_native_abi; then
			mv "${ED}${gamesdir}/libs" "${ED}${gamesdir}/libs_${MULTILIB_ABI_FLAG}"
		fi
	}
	multilib_foreach_abi abi_src_install
}

pkg_postinst() {
	elog "System-wide Dwarf Fortress has been installed to ${gamesdir}. This is"
	elog "symlinked to ~/.dwarf-fortress when dwarf-fortress is run."
	elog "For more information on what exactly is replaced, see /usr/bin/dwarf-fortress."
	elog "Note: This means that the primary entry point is /usr/bin/dwarf-fortress."
	elog "Do not run ${gamesdir}/libs/Dwarf_Fortress."
	elog
	elog "Optional runtime dependencies:"
	elog "Install sys-libs/ncurses[unicode] for [PRINT_MODE:TEXT]"
	elog "Install media-libs/openal and media-libs/libsndfile for audio output"
	elog "Install media-libs/libsdl[opengl] for the OpenGL PRINT_MODE settings"
}
