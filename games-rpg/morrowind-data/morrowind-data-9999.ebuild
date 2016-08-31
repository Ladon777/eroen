# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# $Id$

EAPI=6

PYTHON_COMPAT=(python2_7 python3_3 python3_4 python3_5)
PYTHON_REQ_USE="ssl"
#CHECKREQS_DISK_BUILD="1140M"

inherit eutils linux-info python-any-r1

DESCRIPTION="Data files for Morrowind"
HOMEPAGE="http://www.elderscrolls.com"
SRC_URI="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
LICENSE="all-rights-reserved Morrowind-EULA"
RESTRICT="bindist mirror"

SLOT="0"
KEYWORDS="" # -* ~amd64 ~x86
IUSE=""

DEPEND="${PYTHON_DEPS}
	sys-devel/gcc[cxx]
	amd64? ( sys-devel/gcc[cxx,multilib] )"
RDEPEND=""

STEAM_app_id=22320 # See https://steamdb.info
STEAM_platform=windows # linux, macos, or windows

steam_pkg_setup() {
	# CONFIG_PAX_ELFRELOCS must not be disabled (if present). 
	# Textrels are all over the place :(
	if linux_config_exists; then
		if [[ -n $(linux_chkconfig_string PAX_ELFRELOCS) ]] && \
			! linux_chkconfig_present PAX_ELFRELOCS; then
			die "Need support for x86 TEXTRELs"
		fi
	else
		ewarn "Could not find kernel config. The install will fail later if"
		ewarn "x86 TEXTRELs are not supported on the system."
	fi

	: ${STEAM_CREDS:=/etc/portage/creds_steam}
	if [[ $MERGE_TYPE != binary && ! -r $STEAM_CREDS ]]; then
		die "\$STEAM_CREDS=$STEAM_CREDS is not readable"
	fi

	if [[ -z $STEAM_app_id ]]; then
		die "\$STEAM_app_id is not set"
	fi

	python-any-r1_pkg_setup
}

pkg_setup() { steam_pkg_setup; }

steam_get_cred() {
	[[ -n $1 ]] || die "$FUNCNAME - no argument passed"
	awk "/^${1^^}: /{print \$2}" "$STEAM_CREDS" || die
}

steam_get_mail() {
	printf "%s\n%s\n%s\n" \
		"$(steam_get_cred MAIL_SERVER)" \
		"$(steam_get_cred MAIL_USER)" \
		"$(steam_get_cred MAIL_PASS)" \
		| ${EPYTHON} "$FILESDIR"/steam-mail.py
}

esteamcmd() {
	# Supply password on stdin to avoid leaking it in /proc/$pid/cmdline
	printf "%s\n" "$(steam_get_cred STEAM_PASS)" \
		| ./steamcmd.sh \
		"+@ShutdownOnFailedCommand 1" \
		"+@NoPromptForPassword 0" \
		"+login $(steam_get_cred STEAM_USER)" \
		"$@" \
		"+quit" || die -n "Error $? in $FUNCNAME $*"
}

steam_firstlogin() {
	# make steam up to date
	einfo "Update steam"
	./steamcmd.sh "+quit" || die "unable to run steamcmd.sh"

	# generate 'special access code'
	einfo "Attempt to log in, generate special access code email"
	printf "%s\n" "$(steam_get_cred STEAM_PASS)" \
		| ./steamcmd.sh "+login $(steam_get_cred STEAM_USER)" "+quit"
	if [[ $? == 5 ]]; then
		local i imax=5
		for (( i=1; i<=imax; i++ )); do
			# supply 'special access code'
			einfo "Supply special access code, attempt $i of $imax"
			printf "%s\n" "$(steam_get_cred STEAM_PASS)" \
				| ./steamcmd.sh "+set_steam_guard_code $(steam_get_mail)" \
				"+login $(steam_get_cred STEAM_USER)" \
				"+quit" && break

			(( i < 5 )) || die "Unable to log in"
			sleep 10
		done
	fi

	# verify we can log in
	einfo "Verify we can log in"
	esteamcmd
}

steam_src_unpack() {
	default
	steam_firstlogin

	local cmd_platform=
	[[ -n $STEAM_platform ]] && cmd_platform="+@sSteamCmdForcePlatformType ${STEAM_platform}"

	# fetch our thing to $S
	einfo "Install app_id ${STEAM_app_id}"
	esteamcmd \
		"$cmd_platform" \
		"+force_install_dir ${S}" \
		"+app_update ${STEAM_app_id}"
}

src_unpack() { steam_src_unpack; }

src_install() {
	insinto /usr/share/morrowind-data
	doins -r "Data Files"
	doins Morrowind.ini Journal.htm
	dodoc Bethesda.TXT readme.txt
}
