# By eroen, 2016
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils pax-utils readme.gentoo-r1 humblebundle

DESCRIPTION="Minimalistic subway layout game"
HOMEPAGE="http://dinopoloclub.com/minimetro/"
SRC_URI="MiniMetro-gamma${PV}-linux.tar.gz"
RESTRICT="bindist fetch mirror"
S=$WORKDIR

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

DEPEND=""
RDEPEND="virtual/glu
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXcursor
	sys-devel/gcc[cxx]
	x11-libs/gtk+:2
	x11-libs/gdk-pixbuf:2
	dev-libs/glib:2"

QA_PREBUILT="opt/$PN/MiniMetro.x86_64
	opt/$PN/MiniMetro_Data/Mono/*
	opt/$PN/MiniMetro_Data/Plugins/*"

pkg_setup() {
	use amd64 && arch=x86_64
	use x86 && arch=x86
}

src_prepare() {
	if ! use amd64; then
		rm -rf MiniMetro_Data/Plugins/x86_64 \
			MiniMetro_Data/Mono/x86_64 || die
		rm -f MiniMetro.x86_64 || die
	fi
	if ! use x86; then
		rm -rf MiniMetro_Data/Plugins/x86 \
			MiniMetro_Data/Mono/x86 || die
		rm -f MiniMetro.x86 || die
	fi
}

src_install() {
	insinto /opt/$PN
	doins -r MiniMetro_Data
	doins MiniMetro.$arch
	fperms +x /opt/$PN/MiniMetro.$arch
	pax-mark -m "${ED%/}"/opt/$PN/MiniMetro.$arch

	make_wrapper $PN "\"${EPREFIX%/}/opt/$PN/MiniMetro.$arch\""
	make_desktop_entry $PN "MiniMetro" "${EPREFIX%/}/opt/$PN/MiniMetro_Data/Resources/UnityPlayer.png"

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
