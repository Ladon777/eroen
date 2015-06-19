# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/libeatmydata/libeatmydata-82.ebuild,v 1.1 2013/07/18 14:15:51 slyfox Exp $

EAPI=5
inherit eutils multilib-minimal

DESCRIPTION="LD_PRELOAD hack to convert sync()/msync() and the like to NO-OP"
HOMEPAGE="https://launchpad.net/libeatmydata/"
SRC_URI="https://launchpad.net/${PN}/trunk/${P}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

# sandbox fools LD_PRELOAD and libeatmydata does not get control
# bug/feature in sandbox?
#DEPEND="test? ( dev-util/strace )"
RESTRICT=test

DEPEND="sys-apps/sed"
RDEPEND=""

src_prepare() {
	multilib_copy_sources
}

src_install() {
	multilib-minimal_src_install

	prune_libtool_files --all
	dodoc AUTHORS README
}
