# By eroen <eroen-overlay@occam.eroen.eu>, 2016 - 2017
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6

inherit eutils pax-utils unpacker humblebundle

DESCRIPTION="Lose your mind. Eat your crew."
HOMEPAGE="http://www.failbettergames.com/sunless/"
SRC_URI="Sunless_Sea_Setup_V${PV}LINUX.zip"
RESTRICT="bindist fetch mirror splitdebug"
S=$WORKDIR

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="virtual/glu
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXcursor"

QA_PREBUILT="opt/$PN/*"

src_unpack() {
	default
	unpack_zip "Sunless Sea.sh"
	rm -rf meta scripts "Sunless Sea.sh" || die
}

src_prepare() {
	default

	use amd64 || rm -rf data/x86_64 \
		"data/noarch/Sunless Sea_Data/Plugins/x86_64" \
		"data/noarch/Sunless Sea_Data/Mono/x86_64/libmono.so" || die
	use x86 || rm -rf data/x86 \
		"data/noarch/Sunless Sea_Data/Plugins/x86" \
		"data/noarch/Sunless Sea_Data/Mono/x86/libmono.so" || die

	rm -f data/noarch/README.linux || die
}

src_install() {
	local myarch
	use amd64 && myarch=x86_64
	use x86 && myarch=x86

	insinto /opt/$PN
	doins -r data/noarch/. data/$myarch/. # Executable and resources must be in same place
	fperms +x "/opt/$PN/Sunless Sea.$myarch"
	pax-mark -m "$ED/opt/$PN/Sunless Sea.$myarch" # Required for bundled libmono

	make_wrapper $PN "\"/opt/$PN/Sunless Sea.$myarch\""
	make_desktop_entry $PN "Sunless Sea" /opt/$PN/Icon.png
}
