# By eroen, 2014
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils games

DESCRIPTION="Operational-level wargame covering the 1942/43 Stalingrad campaign"
HOMEPAGE="http://unityofcommand.net/"
SRC_URI="Unity_of_Command_LINUX_v104d.tgz"
RESTRICT="fetch mirror"
S="${WORKDIR}/Unity of Command"

LICENSE="all-rights-reserved BSD FTL LGPL-2.1 libpng MIT ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bundled-libs"

HDEPEND=""
# gcc: libgcc_s needs 4.5, libstdc++ needs 4.6
LIBDEPEND="
	sys-libs/readline
	!bundled-libs? (
		media-libs/alsa-lib[abi_x86_32]
		media-libs/libsdl[abi_x86_32]
		sys-libs/zlib[abi_x86_32]
		>=sys-devel/gcc-4.6.0
		dev-libs/openssl[abi_x86_32]
		media-libs/sdl-image[abi_x86_32]
		=media-libs/libpng-1.2*[abi_x86_32]
		media-libs/sdl-ttf[abi_x86_32]
		media-libs/freetype[abi_x86_32]
		media-libs/sdl-mixer[abi_x86_32]
		media-libs/libvorbis[abi_x86_32]
		media-libs/libogg[abi_x86_32]
		media-libs/flac[abi_x86_32]
		media-libs/libmad[abi_x86_32]
		media-libs/smpeg[abi_x86_32]
		x11-libs/libX11[abi_x86_32]
		x11-libs/libxcb[abi_x86_32]
		x11-libs/libXau[abi_x86_32]
		x11-libs/libXdmcp[abi_x86_32]
		x11-libs/libXext[abi_x86_32]
		x11-libs/libXrender[abi_x86_32]
		x11-libs/libXrandr[abi_x86_32]
		x11-libs/libXcursor[abi_x86_32]
		x11-libs/libXfixes[abi_x86_32]
		dev-libs/expat[abi_x86_32]
		x11-libs/pixman[abi_x86_32]
		media-libs/fontconfig[abi_x86_32]
		dev-libs/glib:2[abi_x86_32]
		dev-libs/libffi[abi_x86_32]
		x11-libs/cairo[abi_x86_32]
		x11-libs/pango[abi_x86_32]
		x11-libs/libXdamage[abi_x86_32]
		)
	"
#DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

MY_PREFIX=${GAMES_PREFIX_OPT}/${P}
#QA_PREBUILT=${MY_PREFIX#/}/bin/\*

pkg_nofetch() {
	elog "Please download ${SRC_URI}"
	elog "from ${HOMEPAGE} or http://humblebundle.com"
	elog "and place it in ${DISTDIR}"
}

src_prepare() {
	rm -r license/ || die
	if ! use bundled-libs; then
		rm bin/{libasound_module_pcm_pulse.so,libasound.so.2} || die
		rm bin/libSDL-1.2.so.0 || die

		rm bin/libz.so.1 || die
		rm bin/{libgcc_s.so.1,libstdc++.so.6,libquadmath.so.0} || die
		rm bin/{libssl.so.1.0.0,libcrypto.so.1.0.0} || die
		rm bin/libSDL_image-1.2.so.0 || die
		rm bin/libpng12.so.0 || die
		# libjpeg.so.8
		rm bin/libSDL_ttf-2.0.so.0 || die
		rm bin/libfreetype.so.6 || die
		rm bin/libSDL_mixer-1.2.so.0 || die
		rm bin/{libvorbisfile.so.3,libvorbis.so.0} || die
		rm bin/libogg.so.0 || die
		rm bin/libFLAC.so.8 || die
		rm bin/libmad.so.0 || die
		rm bin/libsmpeg-0.4.so.0 || die
		rm bin/libX11.so.6 || die
		rm bin/{libxcb.so.1,libxcb-shm.so.0,libxcb-render.so.0} || die
		rm bin/libXau.so.6 || die
		rm bin/libXdmcp.so.6 || die
		rm bin/libXext.so.6 || die
		rm bin/libXrender.so.1 || die
		rm bin/libXrandr.so.2 || die
		rm bin/libXcursor.so.1 || die
		rm bin/libXfixes.so.3 || die
		rm bin/libexpat.so.1 || die
		rm bin/libpixman-1.so.0 || die
		rm bin/libfontconfig.so.1 || die
		rm bin/{libgobject-2.0.so.0,libglib-2.0.so.0,libgmodule-2.0.so.0,libgthread-2.0.so.0} || die
		rm bin/libffi.so.6 || die

		# lockstep
		rm bin/libcairo.so.2 || die
		rm bin/libpangocairo-1.0.so.0 || die
		rm bin/libpango-1.0.so.0 || die
		rm bin/libpangoft2-1.0.so.0 || die

		rm bin/libXdamage.so.1 || die

		# problems:
		# - libpython2.7.so.1.0 not included in e-l-x86 anymore.
	fi
}

src_install() {
	insinto "${MY_PREFIX}"
	doins -r *
	# Creates fontconfig crap in CWD if writeable, falls back to ~/.fontconfig/
	games_make_wrapper ${P} bin/uoc "${MY_PREFIX}" "${MY_PREFIX}/bin"
	prepgamesdirs
	chmod 750 "${D%/}/${MY_PREFIX}"/bin/uoc || die
}
