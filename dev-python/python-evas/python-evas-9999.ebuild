# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

E_CYTHON=1
SUPPORT_PYTHON_ABIS=1
RESTRICT_PYTHON_ABIS="3.*"

if [[ ${PV} == "9999" ]] ; then
	EGIT_SUB_PROJECT="legacy/bindings/python"
	EGIT_URI_APPEND=${PN}
else
	#SRC_URI="http://download.enlightenment.org/releases/${P}.tar.bz2"
	EKEY_STATE="snap"
fi

inherit enlightenment

DESCRIPTION="Python bindings for EVAS library"
HOMEPAGE="http://www.enlightenment.org/"

LICENSE="LGPL-2.1"
IUSE="static-libs"

RDEPEND=">=media-libs/evas-9999"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9.0"

src_prepare() {
	enlightenment_src_prepare
	python_copy_sources
}

src_configure() {
	python_execute_function -s enlightenment_src_configure
}

src_compile() {
	python_execute_function -s enlightenment_src_compile
}

src_install() {
	python_execute_function -s enlightenment_src_install
}
