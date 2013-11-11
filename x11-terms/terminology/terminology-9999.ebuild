# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit enlightenment

DESCRIPTION="Simple EFL based terminal emulator"
HOMEPAGE="http://www.enlightenment.org/"

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
