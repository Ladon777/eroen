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
# png-12: pygame.imageext.so
LIBDEPEND="
	sys-libs/readline
	!bundled-libs? (
		=media-libs/libpng-1.2*[abi_x86_32]
		>=sys-devel/gcc-4.6.0
		dev-libs/expat[abi_x86_32]
		dev-libs/glib:2[abi_x86_32]
		dev-libs/libffi[abi_x86_32]
		dev-libs/openssl[abi_x86_32]
		media-libs/libsdl[abi_x86_32]
		media-libs/sdl-image[abi_x86_32]
		media-libs/sdl-mixer[abi_x86_32]
		media-libs/sdl-ttf[abi_x86_32]
		media-libs/smpeg[abi_x86_32]
		sys-libs/zlib[abi_x86_32]
		x11-libs/cairo[abi_x86_32]
		x11-libs/libX11[abi_x86_32]
		x11-libs/pango[abi_x86_32]
		)
	"
#DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

MY_PREFIX=${GAMES_PREFIX_OPT}/${P}
QA_PREBUILT=${MY_PREFIX#/}/bin/\*

pkg_nofetch() {
	elog "Please download ${SRC_URI}"
	elog "from ${HOMEPAGE} or http://humblebundle.com"
	elog "and place it in ${DISTDIR}"
}

src_prepare() {
	rm -r license/ || die
	if ! use bundled-libs; then
		# problems:
		# - libjpeg.so.8
		# - libgfortran.so.3 - much work to test
		# - libpython2.7.so.1.0 not included in e-l-x86 anymore.
		#     - various python packages
		mv bin bin-old || die
		mkdir bin || die
		cp bin-old/{uoc,libjpeg.so.8,libgfortran.so.3,libpython*,pygame*,numpy*,_ctypes.so,_elementtree.so,_heapq.so,_io.so,_json.so,cairo._cairo.so,datetime.so,glib._glib.so,gobject._gobject.so,greenlet.so,libpyglib*,pango.so,pangocairo.so,pyexpat.so,termios.so,*.3gf} \
			bin/ || die
		rm -r bin-old || die
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
