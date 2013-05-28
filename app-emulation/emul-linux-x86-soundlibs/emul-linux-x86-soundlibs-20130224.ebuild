# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-soundlibs/emul-linux-x86-soundlibs-20130224.ebuild,v 1.3 2013/03/16 15:23:55 pacho Exp $

EAPI=5
inherit emul-linux-x86

LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1 LGPL-2 MIT gsm public-domain"
KEYWORDS="-* amd64"
IUSE="alsa filter-alsa-lib filter-audiofile filter-fftw filter-flac filter-webrtc-audio-processing"

RDEPEND="~app-emulation/emul-linux-x86-baselibs-${PV}
	~app-emulation/emul-linux-x86-medialibs-${PV}
	!>=media-libs/libmikmod-3.2.0-r1[abi_x86_32]
	!filter-fftw? ( !>=sci-libs/fftw-3.3.3-r1[abi_x86_32] )"

src_prepare() {
	_ALLOWED="${S}/etc/env.d"
	use alsa && _ALLOWED="${_ALLOWED}|${S}/usr/bin/aoss"
	ALLOWED="(${_ALLOWED})"

	# media-libs/alsa-lib-1.0.27.1
	if use filter-alsa-lib; then
		rm usr/lib32/alsa-lib/smixer/smixer-{ac97,hda,sbase}.so || die
		rm usr/lib32/libasound.so{,.2,.2.0.0} || die
		rm usr/lib32/pkgconfig/alsa.pc || die
	fi

	# media-libs/audiofile-0.3.6-r1
	if use filter-audiofile; then
		rm usr/lib32/libaudiofile.so{,.1,.1.0.0} || die
		rm usr/lib32/pkgconfig/audiofile.pc || die
	fi

	if use filter-fftw; then
		rm "${S}"/usr/lib32/pkgconfig/fftw3{,f,l}.pc || die "rm 1"
		rm "${S}"/usr/lib32/libfftw3{,f,l}.so{,.3} || die "rm 2"
	fi
	
	# media-libs/flac-1.2.1-r5
	if use filter-flac; then
		rm usr/lib32/libFLAC++.so{,.6,.6.2.0} || die
		rm usr/lib32/libFLAC.so{,.8,.8.2.0} || die
		rm usr/lib32/pkgconfig/flac{,++}.pc || die
	fi

	# 'media-libs/webrtc-audio-processing-0.1-r1
	if use filter-webrtc-audio-processing; then
		rm usr/lib32/libwebrtc_audio_processing.so{,.0,.0.0.0} || die
		rm usr/lib32/pkgconfig/webrtc-audio-processing.pc || die
	fi

	emul-linux-x86_src_prepare

	if use alsa; then
		mv -f "${S}"/usr/bin/aoss{,32} || die
	fi
}
