# By eroen, 2016
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils unpacker humblebundle

DESCRIPTION="Program little office workers to solve puzzles. Be a good employee!"
HOMEPAGE="http://tomorrowcorporation.com/humanresourcemachine"
SRC_URI="${PN}-Linux-${PV//./-}.sh"
RESTRICT="bindist fetch mirror"
S=$WORKDIR

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64" # ~x86
IUSE=""

DEPEND=""
RDEPEND="
	media-libs/libsdl2
	media-libs/openal"

QA_PREBUILT="opt/HumanResourceMachine*"

pkg_setup() {
	use amd64 && myarch=x86_64
	#use x86 && myarch=x86
}

src_unpack() {
	unpack_zip $A
}

src_prepare() {
	mv data/noarch/README.linux "$T" || die
	rm -f data/noarch/LICENSE.txt || die
	rm -rf meta scripts || die
	rm -rf data/*/lib*/ || die
	use amd64 || rm -rf data/x86_64 || die
	use x86 || rm -rf data/x86 || die
}

src_install() {
	insinto /opt/$PN
	doins -r data/{noarch,$myarch}/. # executable and resources must be in same place
	fperms +x /opt/$PN/HumanResourceMachine.bin.$myarch

	make_wrapper ${PN} /opt/$PN/HumanResourceMachine.bin.$myarch /opt/$PN
	make_desktop_entry ${PN} "Human Resource Machine" /opt/$PN/icon.png

	dodoc "$T"/README.linux
}
