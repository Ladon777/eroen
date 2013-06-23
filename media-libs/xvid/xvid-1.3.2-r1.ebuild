# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xvid/xvid-1.3.2-r1.ebuild,v 1.1 2013/06/19 15:51:41 aballier Exp $

EAPI=5
inherit flag-o-matic multilib multilib-minimal

MY_PN=${PN}core
MY_P=${MY_PN}-${PV}

DESCRIPTION="XviD, a high performance/quality MPEG-4 video de-/encoding solution"
HOMEPAGE="http://www.xvid.org/"
SRC_URI="http://downloads.xvid.org/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="examples +threads pic"

NASM=">=dev-lang/nasm-2"
YASM=">=dev-lang/yasm-1"

DEPEND="amd64? ( || ( ${YASM} ${NASM} ) )
	x86? ( || ( ${YASM} ${NASM} ) )
	x86-fbsd? ( || ( ${YASM} ${NASM} ) )"
RDEPEND="abi_x86_32? ( || (
			app-emulation/emul-linux-x86-medialibs[filter-${PN}]
			!<=app-emulation/emul-linux-x86-medialibs-20130224 ) )"

S=${WORKDIR}/${MY_PN}/build/generic

src_prepare() {
	# make build verbose
	sed \
		-e 's/@$(CC)/$(CC)/' \
		-e 's/@$(AS)/$(AS)/' \
		-e 's/@$(RM)/$(RM)/' \
		-e 's/@$(INSTALL)/$(INSTALL)/' \
		-e 's/@cd/cd/' \
		-i Makefile || die
	# Since only the build system is in $S, this will only copy it but not the
	# entire sources.
	multilib_copy_sources
}

multilib_src_configure() {
	use sparc && append-cflags -mno-vis #357149

	local myconf
	if use pic || [[ ${ABI} == "x32" ]] ; then #421841
		myconf="--disable-assembly"
	fi

	econf ${myconf} \
		$(use_enable threads pthread)
}

multilib_src_install() {
	emake DESTDIR="${D}" install

	local mylib=$(basename $(ls "${D}"/usr/$(get_libdir)/libxvidcore.so*))
	dosym ${mylib} /usr/$(get_libdir)/libxvidcore.so
	dosym ${mylib} /usr/$(get_libdir)/${mylib%.?}
}

multilib_src_install_all() {
	dodoc "${S}"/../../{AUTHORS,ChangeLog*,CodingStyle,README,TODO}

	if use examples; then
		insinto /usr/share/${PN}
		doins -r "${S}"/../../examples
	fi
}
