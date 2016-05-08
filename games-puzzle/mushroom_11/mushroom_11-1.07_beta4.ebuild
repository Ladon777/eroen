# By eroen, 2016
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils pax-utils readme.gentoo-r1 humblebundle

DESCRIPTION="Award-winning anti-platformer where destruction is the only way to move"
HOMEPAGE="http://mushroom11.com"
SRC_URI="Mushroom_11_v${PV/_beta/b}_Humble_Linux.zip"
RESTRICT="bindist fetch mirror"
S=$WORKDIR

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="
	virtual/glu
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXcursor
	sys-devel/gcc[cxx]
	x11-libs/gtk+:2
	x11-libs/gdk-pixbuf:2
	dev-libs/glib:2
	"

QA_PREBUILT="opt/mushroom_11/Mushroom_11.*
	opt/mushroom_11/Mushroom_11_Data/Mono/*
	opt/mushroom_11/Mushroom_11_Data/Plugins/*"

pkg_setup() {
	use amd64 && arch=x86_64
	use x86 && arch=x86
}

src_prepare() {
	rm -f Mushroom_11_Data/Plugins/*/libCSteamworks.so \
		Mushroom_11_Data/Plugins/*/libsteam_api.so || die
	if ! use amd64; then
		rm -rf Mushroom_11_Data/Plugins/x86_64 || die
		rm -rf Mushroom_11_Data/Mono/x86_64 || die
		rm -f Mushroom_11.x86_64 || die
	fi
	if ! use x86; then
		rm -rf Mushroom_11_Data/Plugins/x86 || die
		rm -rf Mushroom_11_Data/Mono/x86 || die
		rm -f Mushroom_11.x86 || die
	fi
}

src_install() {
	insinto /opt/$PN
	doins -r Mushroom_11_Data
	doins Mushroom_11.$arch
	fperms +x /opt/$PN/Mushroom_11.$arch
	pax-mark -m "$ED/opt/$PN/Mushroom_11.$arch"

	make_wrapper $PN "\"/opt/$PN/Mushroom_11.$arch\""

	readme.gentoo_create_doc
}
