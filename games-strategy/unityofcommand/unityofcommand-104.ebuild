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
IUSE=""

HDEPEND=""
LIBDEPEND="
	sys-libs/readline
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
}

src_install() {
	insinto "${MY_PREFIX}"
	doins -r *
	# Creates fontconfig crap in CWD if writeable, falls back to ~/.fontconfig/
	games_make_wrapper ${P} bin/uoc "${MY_PREFIX}" "${MY_PREFIX}/bin"
	prepgamesdirs
	chmod 750 "${D%/}/${MY_PREFIX}"/bin/uoc || die
}
