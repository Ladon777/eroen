# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.99.5-r1.ebuild,v 1.1 2013/06/19 17:18:52 aballier Exp $

EAPI=5

inherit autotools eutils multilib-minimal

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${P}-automake-2.12.patch.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="debug mmx mp3rtp sndfile static-libs"

# These deps are without MULTILIB_USEDEP and are correct since we only build
# libmp3lame for multilib and these deps apply to the lame frontend executable.
RDEPEND=">=sys-libs/ncurses-5.7-r7
	sndfile? ( >=media-libs/libsndfile-1.0.2 )
	abi_x86_32? ( || (
			app-emulation/emul-linux-x86-medialibs[filter-${PN}]
			!<=app-emulation/emul-linux-x86-medialibs-20130224 ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	mmx? ( dev-lang/nasm )"

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-3.96-ccc.patch \
		"${FILESDIR}"/${PN}-3.98-gtk-path.patch \
		"${FILESDIR}"/${PN}-3.99.5-tinfo.patch \
		"${WORKDIR}"/${P}-automake-2.12.patch

	mkdir libmp3lame/i386/.libs || die #workaround parallel build with nasm

	sed -i -e '/define sp/s/+/ + /g' libmp3lame/i386/nasm.h || die

	use mmx || sed -i -e '/AC_PATH_PROG/s:nasm:dIsAbLe&:' configure.in #361879

	AT_M4DIR=. eautoreconf
}

is_best_abi() {
	local all_abis=( $(multilib_get_enabled_abis) )
	local best_abi="${all_abis[$(( ${#all_abis[@]} - 1 ))]}"
	[ "${ABI}" = "${best_abi}" ]
}

multilib_src_configure() {
	local myconf
	use mmx && myconf+="--enable-nasm" #361879

	# Only build the frontend for the best ABI.
	if is_best_abi ; then
		myconf+=" $(use_enable mp3rtp)"
		use sndfile && myconf+=" --with-fileio=sndfile"
	else
		myconf+=" --disable-frontend --disable-mp3rtp"
	fi

	ECONF_SOURCE="${S}" econf \
		$(use_enable static-libs static) \
		$(use_enable debug debug norm) \
		--disable-mp3x \
		--enable-dynamic-frontends \
		${myconf}
}

multilib_src_install() {
	emake DESTDIR="${D}" pkghtmldir="${EPREFIX}/usr/share/doc/${PF}/html" install
}

multilib_src_install_all() {
	cd "${S}"
	dobin misc/mlame

	dodoc API ChangeLog HACKING README STYLEGUIDE TODO USAGE
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm

	find "${ED}" -name '*.la' -exec rm -f {} +
}
