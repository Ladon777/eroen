# By eroen, 2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5

inherit eutils games

DESCRIPTION="Combination of platforming and role playing game with many hilarious references"
HOMEPAGE="http://www.unepicgame.com/en/game.html"
# 308.6 MB
# 2014-12-08 17:46
# 940824c4de6e48522845f63423e87783
SRC_URI="${P}-bin-installer-32.run"
S=${WORKDIR}

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64" # ~x86
IUSE=""

LIBDEPEND="
	sys-libs/zlib
	virtual/opengl
	sys-devel/gcc[cxx]
	"
HDEPEND="
	app-admin/chrpath
	"
DEPEND="${HDEPEND}"
RDEPEND="${LIBDEPEND}"

MY_PREFIX=${GAMES_PREFIX_OPT}/${P}
QA_PRESTRIPPED=${MY_PREFIX}/data/unepic.\*

pkg_setup() {
	use amd64 && bitness=64
	#use x86 && bitness=32
}

src_unpack() {
	local srcdir=${DISTDIR}/
	local x=${A}
	local myfail="failure unpacking ${x}"
	# from phase-helpers.sh
	( set +x ; while true ; do echo n || break ; done ) | \
		unzip -qo "${srcdir}${x}"
	[[ $? = 0 ]] || [[ $? = 1 ]] || die "$myfail"
}

src_prepare() {
	rm -rf "${S}"/guis/ || die
	rm -f "${S}"/data/unepic.sh || die
	rm -f "${S}"/data/lib*/libGLEW.so* || die
	# dlopen: libSDL2_mixer-2.0.so.0 -> libvorbisfile.so.3

	for x in "${S}"/data/*{32,64}; do
		if [[ ${x} != *${bitness} ]]; then
			rm -rf "${x}" || die "failed to remove ${x}"
		fi
	done

	chrpath -d "${S}"/data/unepic${bitness} || die
	chrpath -d "${S}"/data/lib${bitness}/libSDL2-2.0.so.0 || die
}

src_install() {
	insinto "${MY_PREFIX}"
	doins -r "${S}"/*

	# exe: data/unepic${bitness}
	# CWD: data/
	# LD_LIBRARY_PATH: data/$(get_libdir)
	games_make_wrapper ${PN} "${MY_PREFIX}"/data/unepic${bitness} \
		"${MY_PREFIX}"/data "${MY_PREFIX}"/data/lib${bitness}
	make_desktop_entry ${PN} Unepic "${MY_PREFIX}"/data/unepic.png

	prepgamesdirs
	fperms ug+x "${MY_PREFIX}"/data/unepic${bitness}
}
