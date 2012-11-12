# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/octave/octave-3.6.3.ebuild,v 1.1 2012/10/26 18:27:13 bicatali Exp $

EAPI=4

AUTOTOOLS_AUTORECONF=1
AUTOTOOLS_IN_SOURCE_BUILD=1

inherit autotools-utils toolchain-funcs fortran-2

DESCRIPTION="High-level interactive language for numerical computations"
LICENSE="GPL-3"
HOMEPAGE="http://www.octave.org/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

SLOT="0"
IUSE="curl doc fftw +glpk gnuplot hdf5 +imagemagick opengl +qhull +qrupdate
	readline +sparse static-libs X zlib"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-fbsd ~x86-linux"

RDEPEND="dev-libs/libpcre
	app-text/ghostscript-gpl
	sys-libs/ncurses
	virtual/lapack
	curl? ( net-misc/curl )
	fftw? ( sci-libs/fftw:3.0 )
	glpk? ( sci-mathematics/glpk )
	gnuplot? ( sci-visualization/gnuplot )
	hdf5? ( sci-libs/hdf5 )
	imagemagick? ( || (
			media-gfx/graphicsmagick[cxx]
			media-gfx/imagemagick[cxx] ) )
	opengl? (
		media-libs/freetype:2
		media-libs/fontconfig
		>=x11-libs/fltk-1.3:1[opengl] )
	qhull? ( media-libs/qhull )
	qrupdate? ( sci-libs/qrupdate )
	readline? ( sys-libs/readline )
	sparse? (
		sci-libs/arpack
		sci-libs/camd
		sci-libs/ccolamd
		sci-libs/cholmod
		sci-libs/colamd
		sci-libs/cxsparse
		sci-libs/umfpack )
	X? ( x11-libs/libX11 )
	zlib? ( sys-libs/zlib )"

DEPEND="${RDEPEND}
	doc? (
		virtual/latex-base
		dev-texlive/texlive-genericrecommended
		sys-apps/texinfo )
	dev-util/gperf
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/${PN}-3.4.3-{pkgbuilddir,help,texi}.patch )

src_prepare() {
	# nasty prefix hack for fltk:1 linking
	if use prefix && use opengl; then
		sed -i \
			-e "s:ldflags\`:ldflags\` -Wl,-rpath,${EPREFIX}/usr/$(get_libdir)/fltk-1:" \
			configure.ac
	fi
	autotools-utils_src_prepare
}

src_configure() {
	# occasional fail on install, force regeneration (bug #401189)
	rm doc/interpreter/contributors.texi || die

	local myconf="--without-magick"
	if use imagemagick; then
		if has_version media-gfx/graphicsmagick[cxx]; then
			myconf="--with-magick=GraphicsMagick"
		else
			myconf="--with-magick=ImageMagick"
		fi
	fi

	# unfortunate dependency on mpi from hdf5 (bug #302621)
	use hdf5 && has_version sci-libs/hdf5[mpi] && \
		export CXX=mpicxx CC=mpicc FC=mpif77 F77=mpif77

	local myeconfargs+=(
		--localstatedir="${EPREFIX}/var/state/octave"
		--with-blas="$(pkg-config --libs blas)"
		--with-lapack="$(pkg-config --libs lapack)"
		$(use_enable doc docs)
		$(use_enable readline)
		$(use_with curl)
		$(use_with fftw fftw3)
		$(use_with fftw fftw3f)
		$(use_with glpk)
		$(use_with hdf5)
		$(use_with opengl)
		$(use_with qhull)
		$(use_with qrupdate)
		$(use_with sparse arpack)
		$(use_with sparse umfpack)
		$(use_with sparse colamd)
		$(use_with sparse ccolamd)
		$(use_with sparse cholmod)
		$(use_with sparse cxsparse)
		$(use_with X x)
		$(use_with zlib z)
		${myconf}
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install
	use doc && dodoc $(find doc -name \*.pdf)
	[[ -e test/fntests.log ]] && dodoc test/fntests.log
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/${P}" > 99octave
	doenvd 99octave
}
