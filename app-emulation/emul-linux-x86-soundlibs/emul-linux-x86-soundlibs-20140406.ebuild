# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit emul-linux-x86

LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1 LGPL-2 MIT gsm public-domain"
KEYWORDS="-* ~amd64"
IUSE="abi_x86_32 alsa +pulseaudio"

RDEPEND="~app-emulation/emul-linux-x86-baselibs-${PV}[abi_x86_32=]
	~app-emulation/emul-linux-x86-medialibs-${PV}[abi_x86_32=]
	!abi_x86_32? ( !>=sci-libs/fftw-3.3.3-r1[abi_x86_32]
		!>=media-libs/libmikmod-3.2.0-r1[abi_x86_32] )
	abi_x86_32? (
		>=media-libs/libogg-1.3.1[abi_x86_32(-)]
		>=media-libs/libvorbis-1.3.3-r1[abi_x86_32(-)]
		>=media-libs/libmodplug-0.8.8.4-r1[abi_x86_32(-)]
		>=media-sound/gsm-1.0.13-r1[abi_x86_32(-)]
		>=media-libs/webrtc-audio-processing-0.1-r1[abi_x86_32(-)]
		>=media-libs/alsa-lib-1.0.27.1-r1[abi_x86_32(-)]
		>=media-libs/flac-1.2.1-r5[abi_x86_32(-)]
		>=media-libs/audiofile-0.3.6-r1[abi_x86_32(-)]
		>=sci-libs/fftw-3.3.3-r1[abi_x86_32(-)]
		>=media-libs/ladspa-sdk-1.13-r2[abi_x86_32(-)]
		>=media-plugins/caps-plugins-0.4.5-r2[abi_x86_32(-)]
		>=media-plugins/swh-plugins-0.4.15-r3[abi_x86_32(-)]
		>=media-libs/libmikmod-3.2.0-r1[abi_x86_32(-)]
		>=media-plugins/alsaequal-0.6-r1[abi_x86_32(-)]
		>=media-sound/cdparanoia-3.10.2-r6[abi_x86_32(-)]
		>=media-sound/wavpack-4.60.1-r1[abi_x86_32(-)]
		>=media-sound/musepack-tools-465-r1[abi_x86_32(-)]
		>=media-libs/libsndfile-1.0.25-r1[abi_x86_32(-)]
		>=media-libs/libsamplerate-0.1.8-r1[abi_x86_32(-)]
		>=media-sound/twolame-0.3.13-r1[abi_x86_32(-)]
		>=media-sound/jack-audio-connection-kit-0.121.3-r1[abi_x86_32(-)]
		>=media-libs/portaudio-19_pre20111121-r1[abi_x86_32(-)]
		>=media-sound/mpg123-1.15.4-r1[abi_x86_32(-)]
		>=media-libs/libao-1.1.0-r1[abi_x86_32(-)]
		pulseaudio? ( >=media-sound/pulseaudio-4.0-r1[abi_x86_32(-)] )
	)"

pkg_pretend() {
	if use abi_x86_32 && ! use pulseaudio; then
		ewarn "You have disabled USE=pulseaudio. This is known to break pre-built"
		ewarn "libavfilter in emul-linux-x86-medialibs. If you need that, please"
		ewarn "turn USE=pulseaudio back on."
	fi
}

src_prepare() {
	_ALLOWED="${S}/etc/env.d"
	use alsa && _ALLOWED="${_ALLOWED}|${S}/usr/bin/aoss"
	ALLOWED="(${_ALLOWED})"

	emul-linux-x86_src_prepare

	if use alsa; then
		mv -f "${S}"/usr/bin/aoss{,32} || die
	fi

	# Remove migrated stuff.
	use abi_x86_32 && rm -f $(cat "${FILESDIR}/remove-native-${PVR}")
}
