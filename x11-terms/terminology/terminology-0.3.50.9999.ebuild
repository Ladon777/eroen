# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

EGIT_SUB_PROJECT=apps
EGIT_URI_APPEND=${PN}
EGIT_COMMIT=016faae65041a1f5c56b3ddf4c34e71ee2cc0ffe
inherit enlightenment

DESCRIPTION="Simple EFL based terminal emulator"
HOMEPAGE="http://www.enlightenment.org/"

KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/ecore-1.7.0[evas]
	>=dev-libs/eet-1.7.0
	>=dev-libs/efreet-1.7.0
	>=dev-libs/eina-1.7.0
	>=dev-libs/eio-1.7.0
	>=dev-libs/embryo-1.7.0
	>=media-libs/elementary-1.7.0
	>=media-libs/evas-1.7.0
	>=media-libs/edje-1.7.0
	>=media-libs/emotion-1.7.0
	media-libs/freetype:2"
DEPEND="${RDEPEND}"
