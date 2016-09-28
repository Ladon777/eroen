# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# $Id$

EAPI=6

inherit linux-info

DESCRIPTION="Used by steam.eclass"
HOMEPAGE="https://developer.valvesoftware.com/wiki/SteamCMD"
SRC_URI="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
LICENSE="all-rights-reserved"
RESTRICT="bindist mirror"
S=$WORKDIR

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	sys-devel/gcc[cxx]
	amd64? ( sys-devel/gcc[cxx,multilib] )"

pkg_setup() {
	# CONFIG_PAX_ELFRELOCS must not be disabled (if present).
	# Textrels are all over the place :(
	if linux_config_exists; then
		if [[ -n $(linux_chkconfig_string PAX_ELFRELOCS) ]] && \
			! linux_chkconfig_present PAX_ELFRELOCS &&
			[[ -z $I_KNOW_WHAT_I_AM_DOING ]]; then
			die "$PN needs support for x86 TEXTRELs to run"
		fi
	else
		ewarn "Could not find kernel config. The install will fail later if"
		ewarn "x86 TEXTRELs are not supported on the system."
	fi
}

src_unpack() {
	default
}

src_install() {
	exeinto /opt/steamcmd/linux32
	doexe linux32/steamcmd
	exeinto /opt/steamcmd
	doexe steamcmd.sh
}
