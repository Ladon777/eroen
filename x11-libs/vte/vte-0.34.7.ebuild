# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.34.7.ebuild,v 1.1 2013/07/08 17:19:38 pacho Exp $

EAPI="5"
GCONF_DEBUG="yes"

inherit eutils gnome2

DESCRIPTION="Library providing a virtual terminal emulator widget"
HOMEPAGE="https://live.gnome.org/Terminal/VTE"

LICENSE="LGPL-2+"
SLOT="2.90"
IUSE="debug glade +introspection termite-patch"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~x64-solaris ~x86-solaris"

PDEPEND="=x11-libs/gnome-pty-helper-${PV}"
RDEPEND="
	>=dev-libs/glib-2.31.13:2
	>=x11-libs/gtk+-3.1.9:3[introspection?]
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/libXft

	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0 )
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	if [[ ${CHOST} == *-interix* ]]; then
		G2CONF="${G2CONF} --disable-Bsymbolic"

		# interix stropts.h is empty...
		export ac_cv_header_stropts_h=no
	fi

	DOCS="AUTHORS ChangeLog HACKING NEWS README"

	# https://bugzilla.gnome.org/show_bug.cgi?id=663779
	epatch "${FILESDIR}/${PN}-0.30.1-alt-meta.patch"

	use termite-patch && epatch "${FILESDIR}"/${PN}-0.32.2-expose_select_text.patch

	gnome2_src_prepare
}

src_configure() {
	# Python bindings are via gobject-introspection
	# Ex: from gi.repository import Vte
	# Do not disable gnome-pty-helper, bug #401389
	gnome2_src_configure \
		--disable-deprecation \
		--disable-static \
		$(use_enable debug) \
		$(use_enable glade glade-catalogue) \
		$(use_enable introspection)
}

src_install() {
	gnome2_src_install
	rm -v "${ED}usr/libexec/gnome-pty-helper" || die
}
