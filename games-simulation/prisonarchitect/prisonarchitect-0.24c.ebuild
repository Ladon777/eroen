# By eroen, 2014
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils games

MY_PV=${PV/#0./alpha}
MY_P=${PN}-${MY_PV}

DESCRIPTION=""
HOMEPAGE="http://www.prison-architect.com"
SRC_URI="${MY_P}-linux.tar.gz"
S=${WORKDIR}/${MY_P}-linux

# introversion.co.uk/legal
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE="unpack-resources"

# TODO:
#GLIBC_2.11 - 2.18 in glibc 2.19
#GLIBCXX_3.4.15 - 3.4.16 in gcc 4.6.4
#Warning: mipmaps requested for non-power-of-two image (1200x343), will break on OpenGL ES
#ogg/vorbis audio
#png, bmp graphics
HDEPEND="unpack-resources? ( app-arch/unrar )"
LIBDEPEND="
	media-libs/libsdl2
	>=sys-devel/gcc-4.6.4
	sys-libs/glibc
	virtual/glu
	virtual/opengl
	"
DEPEND=""
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

MY_PREFIX=${GAMES_PREFIX_OPT}/${P}
use amd64 && MY_ARCH=x86_64
use x86 && MY_ARCH=i686
QA_PREBUILT=("${MY_PREFIX#/}"/PrisonArchitect.${MY_ARCH})

src_install() {
	insinto "${MY_PREFIX}"
	if use unpack-resources; then
		unrar x -idq -o+ main.dat || die
		unrar x -idq -o+ sounds.dat || die
		doins -r data
	else
		doins main.dat sounds.dat
	fi

	exeinto "${MY_PREFIX}"
	doexe PrisonArchitect.${MY_ARCH}

	# Provided wrapper is broken
	games_make_wrapper ${PN} ./PrisonArchitect.${MY_ARCH} "${MY_PREFIX}"
}
