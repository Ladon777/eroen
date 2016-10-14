# By eroen <eroen-overlay@occam.eroen.eu>, 2014-2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=5

inherit eutils

DESCRIPTION="SLIP/PPP emulator using a dial up shell account"
HOMEPAGE="http://slirp.sourceforge.net
	https://packages.qa.debian.org/s/slirp.html"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV%.*}.orig.tar.gz
	mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV%.*}-${PV##*.}.debian.tar.gz"
S=${WORKDIR}/${P%.*}/src

LICENSE="DES"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

src_prepare() {
	pushd "${WORKDIR}"/${P%.*} 2>/dev/null || die
	epatch "${WORKDIR}"/debian/patches/*.patch
	popd 2>/dev/null || die
}

src_configure() {
	local BUILDDIR
	BUILDDIR=${WORKDIR}/${P}_build
	mkdir "${BUILDDIR}" || die
	pushd "${BUILDDIR}" 2>/dev/null || die
	ECONF_SOURCE=${S} \
		econf
	popd 2>/dev/null || die

	BUILDDIR=${WORKDIR}/${P}_build-fullbolt
	mkdir "${BUILDDIR}" || die
	pushd "${BUILDDIR}" 2>/dev/null || die
	ECONF_SOURCE=${S} \
		CFLAGS="${CFLAGS} -DFULL_BOLT" \
		econf
	popd 2>/dev/null || die
}

src_compile() {
	local BUILDDIR
	BUILDDIR=${WORKDIR}/${P}_build
	pushd "${BUILDDIR}" 2>/dev/null || die
	emake
	popd 2>/dev/null || die

	BUILDDIR=${WORKDIR}/${P}_build-fullbolt
	pushd "${BUILDDIR}" 2>/dev/null || die
	emake
	popd 2>/dev/null || die
}

src_install() {
	dobin "${WORKDIR}"/${P}_build/slirp
	newman slirp.man slirp.3
	newbin "${WORKDIR}"/${P}_build-fullbolt/slirp slirp-fullbolt
	doman "${WORKDIR}"/debian/slirp-fullbolt.1

	pushd "${WORKDIR}"/${P%.*} 2>/dev/null || die
	dodoc ChangeLog README README.NEXT slirp-1.0.17/Changes-1.0.17 TODO TODO.old
	dodoc -r docs
	popd 2>/dev/null || die
	dodoc "${WORKDIR}"/debian/README.Debian
}
