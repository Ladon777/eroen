# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# $Id$

# @ECLASS: steam.eclass
# @MAINTAINER:
# eroen <eroen-overlay@occam.eroen.eu>
# @AUTHOR:
# eroen <eroen-overlay@occam.eroen.eu>
# @BLURB: Eclass for fetching packages from Steam
# @DESCRIPTION:
# Conveiniently set up and authenticates with steamcmd and use it to install
# applications.

# steamcmd documentation:
# https://developer.valvesoftware.com/wiki/SteamCMD

case "${EAPI:-0}" in
	6)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

[[ -z ${PYTHON_COMPAT[*]} ]] && PYTHON_COMPAT=(python2_7 python3_3 python3_4 python3_5)
[[ -n $PYTHON_REQ_USE ]] && PYTHON_REQ_USE="$PYTHON_REQ_USE "
PYTHON_REQ_USE="$PYTHON_REQ_USEssl"
inherit linux-info python-any-r1

EXPORT_FUNCTIONS pkg_setup src_unpack

SRC_URI="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"

DEPEND="${PYTHON_DEPS}
	sys-devel/gcc[cxx]
	amd64? ( sys-devel/gcc[cxx,multilib] )"

# @ECLASS-VARIABLE: STEAM_app_id
# @DEFAULT_UNSET
# @DESCRIPTION:
# Steam App ID for steam_src_unpack to install. This must be set before
# steam_src_unpack is called. The App ID for an application can be found on
# https://steamdb.info

# @ECLASS-VARIABLE: STEAM_platform
# @DEFAULT_UNSET
# @DESCRIPTION:
# If this is set, steam_src_unpack will override the current platform in order
# to install non-native application. Possible values are: "linux", "macos", and "windows".

# @ECLASS-VARIABLE: STEAM_CREDS
# @DESCRIPTION:
# Path to credentials file. If unset, the default /etc/portage/creds_steam will
# be used.
#
# This file should be created by the user, and contain the following:
#
# @CODE
# STEAM_USER: mysteamusername
# STEAM_PASS: mysteampassword
# MAIL_SERVER: imap.mymailhost.com
# MAIL_USER: myemailusername
# MAIL_PASS: myemailpassword
# @CODE
#
# Note that the file must be readable by the user your package manager runs as.
#
# The STEAM_* settings will be used to authenticate with Steam, while the
# MAIL_* settings will be used to obtain the verification code required for new
# Steam installations.  If Steam Guard is disabled from
# https://store.steampowered.com/twofactor/manage_action the MAIL_* settings
# can be omitted.
#
# MAIL_SERVER should refer to an imap4/TLS server on port 993 that supports
# PLAIN authentication. For gmail, this must be explicitly enabled by the user.
# Only the folder named "INBOX" will be checked.
: ${STEAM_CREDS:=/etc/portage/creds_steam}

# @ECLASS-VARIABLE: STEAM_FILESDIR
# @INTERNAL
# @DESCRIPTION:
# Directory where the eclass expects to find its internal files.
STEAM_FILESDIR="${BASH_SOURCE[0]%/*}/files"

# @FUNCTION: steam_pkg_setup
# @DESCRIPTION:
# This function is exported. It makes sanity checks and fails early for some
# issues, and sets up the python interpreter.
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

	python-any-r1_pkg_setup
}

# @FUNCTION: steam_get_cred
# @INTERNAL
# @DESCRIPTION:
# Takes 1 argument, prints the corresponding value from STEAM_CREDS.
steam_get_cred() {
	[[ -n $1 ]] || die "$FUNCNAME - no argument passed"
	awk "/^${1^^}: /{print \$2}" "$STEAM_CREDS" || die
}

# @FUNCTION: steam_get_mail
# @INTERNAL
# @DESCRIPTION:
# Prints the verification code required to log in to Steam from a new
# installation. The code is obtained through IMAP, see the description of
# STEAM_CREDS
steam_get_mail() {
	printf "%s\n%s\n%s\n" \
		"$(steam_get_cred MAIL_SERVER)" \
		"$(steam_get_cred MAIL_USER)" \
		"$(steam_get_cred MAIL_PASS)" \
		| ${EPYTHON} "${STEAM_FILESDIR}"/steam-mail.py
}

# @FUNCTION: esteamcmd
# @DESCRIPTION:
# Runs steamcmd.sh with some boilerplate and passes it any arguments. Uses the
# credentials from STEAM_CREDS to log in. This is normally called by
# steam_src_install, but it can be used directly for specific uses.
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

# @FUNCTION: steam_firstlogin
# @DESCRIPTION:
# Runs steamcmd.sh several times in order to bring it up to date, generate the
# verfication code email, and complete authentication. This is normally called
# by steam_src_install, and must be called before esteamcmd.
steam_firstlogin() {
	# make steam up to date
	einfo "Update steam"
	./steamcmd.sh "+quit" || die "unable to run steamcmd.sh"

	# generate the 'special access code'
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

# @FUNCTION: steam_src_unpack
# @DESCRIPTION:
# Runs steam_firstlogin, then uses esteamcmd to install the application
# referred to by STEAM_app_id into S. STEAM_platform can be set to force a
# non-native platform.
#
# This function is exported.
steam_src_unpack() {
	if [[ -z $STEAM_app_id ]]; then
		die "\$STEAM_app_id is not set, $FUNCNAME cannot be used"
	fi

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
