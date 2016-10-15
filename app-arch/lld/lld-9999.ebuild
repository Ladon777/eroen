# By eroen <eroen-overlay@occam.eroen.eu>, 2013 - 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=5

inherit eutils flag-o-matic multilib cmake-utils subversion

DESCRIPTION="The LLVM Linker"
HOMEPAGE="http://lld.llvm.org/"
ESVN_REPO_URI="http://llvm.org/svn/llvm-project/lld/trunk"
SRC_URI=""

LICENSE="UoI-NCSA"
SLOT="0"
#KEYWORDS="~amd64"
IUSE=""

LIBDEPEND="
	|| ( ( 	>=sys-devel/clang-3.1
			sys-libs/libcxx )
		>=sys-devel/gcc-4.7:* )
"
RDEPEND="${LIBDEPEND}"
DEPEND="${LIBDEPEND}"
HDEPEND="
	>=dev-util/cmake-2.8
	"

src_unpack() {
	ESVN_PROJECT=llvm \
		subversion_fetch \
		"http://llvm.org/svn/llvm-project/llvm/trunk"
	ESVN_PROJECT=lld \
		S="${S}"/tools/lld \
		subversion_fetch \
		"http://llvm.org/svn/llvm-project/lld/trunk"
}

src_prepare() {
	cd "${S}"/tools/lld
	epatch_user
	default
}

src_configure() {
	append-cxxflags -std=c++11
	append-ldflags -L/usr/lib64/llvm
	# Shared libraries needs a release, so we can have corresponding libs
	# installed.
	local myLIBDIR="$(get_libdir)"
	mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DLLVM_LIBDIR_SUFFIX=${myLIBDIR#lib}
		-DLLVM_BUILD_RUNTIME=OFF
		-DLLVM_INCLUDE_RUNTIME=OFF
		-DLLVM_ENABLE_ASSERTIONS=ON
		-DLLVM_ENABLE_BACKTRACES=ON
		-DLLVM_LIT_ARGS=-v
		)
		#Debug use flag?
			#-DLLVM_ENABLE_ASSERTIONS=OFF
			#-DLLVM_ENABLE_BACKTRACES=OFF
		#Figure out how targets are set in cmake
			#-DLLVM_TARGETS_TO_BUILD=host:cpp
	tc-export CC CXX
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile lld
}

src_test() {
	# This builds (most?) of llvm too.
	cd "${BUILD_DIR}"
	emake check-lld
}

src_install() {
	cd "${BUILD_DIR}"/tools/lld
	emake DESTDIR="${D}" install

	dosym /usr/bin/lld /usr/lib/${P}/bin/ld || die
}

pkg_postinst() {
	elog "To use lld with your compiler of choice, add something like "
	elog "    -B/usr/lib/lld-9999/bin"
	elog "to your LDFLAGS."
}
