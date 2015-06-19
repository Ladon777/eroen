# By eroen, 2014
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils games

DESCRIPTION="Operational-level wargame covering the 1942/43 Stalingrad campaign"
HOMEPAGE="http://unityofcommand.net/"
SRC_URI="Unity_of_Command_LINUX_v${PV}.tgz"
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

# @FUNCTION: dedup
# @USAGE: <dir to scan>
# @DESCRIPTION:
# Replaces duplicate files in <dir to scan> with hardlinks. To avoid hardlinks
# being broken later on, this should probably be used on a path in ${D} after
# the normal install procedure in src_install().
#
# Duplicates are detected with cksum(1). Newlines are used internally to
# separate file paths.
#
# The following example src_install function runs the default src_install
# phase function, then deduplicates files installed to /usr/share.
# @CODE
#		src_install() {
#			default
#			dedup "${D%/}"/usr/share
#		}
# @CODE
#
# bash, find, cksum, cut, sort, uniq, grep, rm, ln
# not previously used in eutils: cksum, cut, uniq, ln (all coreutils)
# uses emktemp, eumask_{push,pop} from eutils
dedup() {
	local dir=${1%/}
	local listfile=$(emktemp)

	einfo "Scanning for duplicated files in ${dir} ..."
	[[ -d ${dir} ]] || die "${dir} is not a directory"

	# Use a temporary file to simplify using 'cksum' output for 'uniq' input.
	eumask_push 177
	find "${dir}" -type f -exec cksum '{}' \+ > "${listfile}" || die
	eumask_pop

	cut -s -d " " -f "-2" "${listfile}" |
		sort |
		uniq -d |
		while IFS= read -r line; do
			local orig=
			grep -e "^${line} " "${listfile}" |
				cut -s -d ' ' -f 3- |
				while IFS= read -r file; do
					if [[ -z "${orig}" ]]; then
						orig=${file}
						einfo "Deduplicating copies of ${orig#${dir}} ..."
						continue
					else
						einfo "Hardlinking ${file#${dir}} ..."
						[[ -f ${orig} ]] || die "${orig} is not a regular file"
						[[ -f ${file} ]] || die "${file} is not a regular file"
						rm -f "${file}" || die
						ln "${orig}" "${file}" || die
					fi
				done
		done
	rm -f "${listfile}" || die
}

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
	dedup "${D%/}${MY_PREFIX}"
	# Creates fontconfig crap in CWD if writeable, falls back to ~/.fontconfig/
	games_make_wrapper ${P} bin/uoc "${MY_PREFIX}" "${MY_PREFIX}/bin"
	make_desktop_entry ${P} ${P} "${MY_PREFIX}"/data/uoc_icon_big.png
	prepgamesdirs
	chmod 750 "${D%/}/${MY_PREFIX}"/bin/uoc || die
}
