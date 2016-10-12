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

# General steamcmd documentation:
# https://developer.valvesoftware.com/wiki/SteamCMD

case "${EAPI:-0}" in
	6)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

[[ -z ${PYTHON_COMPAT[*]} ]] && PYTHON_COMPAT=(python2_7 python3_3 python3_4 python3_5)
PYTHON_REQ_USE="${PYTHON_REQ_USE}${PYTHON_REQ_USE:+,}ssl"
inherit linux-info python-any-r1

EXPORT_FUNCTIONS pkg_setup src_unpack

DEPEND="${PYTHON_DEPS}
	net-misc/steamcmd-bin"

# @ECLASS-VARIABLE: STEAM_app_id
# @DEFAULT_UNSET
# @DESCRIPTION:
# Steam App ID for steam_src_unpack to fetch.  This must be set before
# steam_src_unpack is called.  The App ID for an application can be found on
# https://steamdb.info

# @ECLASS-VARIABLE: STEAM_ANON
# @DESCRIPTION:
# Set this to "yes" if the application can be fetched with anonymous login.
: ${STEAM_ANON:=no}

# @ECLASS-VARIABLE: STEAM_platform
# @DEFAULT_UNSET
# @DESCRIPTION:
# If this is non-empty, steam_src_unpack will override the current platform in
# order to fetch applications for other platforms.  Possible values are:
# "linux", "macos", and "windows".  This is useful if you only want to install
# non-executable data files.

# @ECLASS-VARIABLE: STEAM_CREDS
# @DESCRIPTION:
# Path to credentials file.  This should not be set in ebuilds, it is meant as
# user configuration.  This file not required if EVCS_OFFLINE is non-empty, nor
# for packages that set STEAM_ANON.  Note that this file must be readable by
# the user your package manager runs as.
#
# This file should be created by the user, and has the following format:
#
# @CODE
# STEAM_USER: mysteamusername
# STEAM_PASS: mysteampassword
# MAIL_SERVER: imap.mymailhost.com
# MAIL_USER: myemailusername
# MAIL_PASS: myemailpassword
# @CODE
#
# The STEAM_* settings are used to authenticate with Steam.  The MAIL_*
# settings are used to obtain the 'special access code' required to
# authenticate accounts with 'Steam Guard' enabled.
#
# Authenticating with 'Steam Guard' is highly experimental and expected to be
# fragile.  It is recommended to instead disable 'Steam Guard' by visiting
# https://store.steampowered.com/twofactor/manage_action
#
# If supplied, MAIL_SERVER should refer to an imap4/TLS server on port 993 that
# supports PLAIN authentication.  For gmail, PLAIN authentication must be
# explicitly enabled.  Only the IMAP folder named "INBOX" will be checked.
: ${STEAM_CREDS:=${EPREFIX%/}/etc/portage/creds_steam}

# @ECLASS-VARIABLE: STEAM_CACHEDIR
# @DESCRIPTION:
# Location for caching downloaded files between runs of the ebuild.  To disable
# caching, set this to zero-length string.
#
# This should not be set by ebuilds, it is meant for user configuration.
# STEAM_CACHEDIR ?= ${DISTDIR}/steam-cache

# @ECLASS-VARIABLE: EVCS_OFFLINE
# @DEFAULT_UNSET
# @DESCRIPTION:
# If non-empty, this variable prevents any online operations.
#
# If this is enabled, STEAM_CACHEDIR must not be empty and a cache must exist
# for the current STEAM_app_id.
#
# This should not be set by ebuilds, it is meant for user configuration.

# @ECLASS-VARIABLE: STEAM_FILESDIR
# @INTERNAL
# @DESCRIPTION:
# Directory where the eclass expects to find its internal files.
STEAM_FILESDIR="${BASH_SOURCE[0]%/*}/files"

# @ECLASS-VARIABLE: STEAM_STEAMCMD
# @INTERNAL
# @DESCRIPTION:
# Absolute path to our copy of steamcmd.sh
STEAM_STEAMCMD=$T/steamcmd/steamcmd.sh

# @FUNCTION: steam_pkg_setup
# @DESCRIPTION:
# This function is exported.  It performs sanity checks and fails early for
# some issues, and sets up the python interpreter (used for email checking
# script).
steam_pkg_setup() {
	if [[ $MERGE_TYPE != binary ]]; then
		if [[ -n $EVCS_OFFLINE ]]; then
			if [[ -v STEAM_CACHEDIR && -z $STEAM_CACHEDIR ]]; then
				die "EVCS_OFFLINE is set, but STEAM_CACHEDIR is set to an empty value."
			fi
		else
			# CONFIG_PAX_ELFRELOCS must not be disabled (if present, only with grsecurity).
			# Textrels are all over the place :(
			if linux_config_exists; then
				if [[ -n $(linux_chkconfig_string PAX_ELFRELOCS) ]] && \
					! linux_chkconfig_present PAX_ELFRELOCS; then
					die "steamcmd needs support for x86 TEXTRELs to run"
				fi
			else
				ewarn "Could not find kernel config.  The install will fail later if"
				ewarn "x86 TEXTRELs are not supported on the system."
			fi

			if [[ yes != ${STEAM_ANON,,} && ! -r $STEAM_CREDS ]]; then
				die "STEAM_CREDS=$STEAM_CREDS is not readable"
			fi
		fi
	fi

	python-any-r1_pkg_setup
}

# @FUNCTION: steam_get_cred
# @INTERNAL
# @DESCRIPTION:
# Takes 1 argument, prints the corresponding value from STEAM_CREDS.
steam_get_cred() {
	[[ 1 == $# ]] || die "$FUNCNAME - wrong number of arguments, expected 1"
	[[ -n $1 ]] || die "$FUNCNAME - passed empty argument"
	if [[ yes = $STEAM_ANON ]]; then
		case "$1" in
			STEAM_USER)
				printf "anonymous\n"
				;;
			*)
				printf "\n"
				;;
		esac
	else
		awk "/^${1^^}: /{print \$2}" "$STEAM_CREDS" || die
	fi
}

# @FUNCTION: steam_get_mail
# @INTERNAL
# @DESCRIPTION:
# Prints the verification code required to authenticate 'Steam Guard' enabled
# accounts with Steam.  The 'special access code' is obtained through IMAP, see
# the documentation for STEAM_CREDS
steam_get_mail() {
	printf "%s\n%s\n%s\n" \
		"$(steam_get_cred MAIL_SERVER)" \
		"$(steam_get_cred MAIL_USER)" \
		"$(steam_get_cred MAIL_PASS)" \
		| ${EPYTHON} "${STEAM_FILESDIR}"/steam-mail.py
}

# @FUNCTION: esteamcmd
# @DESCRIPTION:
# Runs steamcmd.sh with some boilerplate and passes it any arguments.  Assumes
# credentials have already been supplied to steamcmd to enable passwordless
# login.  This is normally called by steam_src_install, but it can be used
# directly for specialty use.
esteamcmd() {
	# Credentials are not passed, already supplied by steam_firstlogin
	"$STEAM_STEAMCMD" \
		"+@ShutdownOnFailedCommand 1" \
		"+@NoPromptForPassword 1" \
		"+login $(steam_get_cred STEAM_USER)" \
		"$@" \
		"+quit" || die -n "Error $? in $FUNCNAME $*"
}

# @FUNCTION: steam_firstlogin
# @DESCRIPTION:
# Run steamcmd.sh several times in order to bring it up to date and
# login/authenticate with Steam.  For 'Steam Guard' enabled accounts, obtaining
# the 'special access code' by imap is attempted.  This is normally called by
# steam_src_install, and must be called before esteamcmd.
steam_firstlogin() {
	# Ensure steamcmd is up to date
	einfo "Update steamcmd"
	"$STEAM_STEAMCMD" "+quit" || die "Unable to run steamcmd.sh"

	# Attempt to log in
	# Supply password on stdin to avoid leaking it in /proc/$pid/cmdline
	einfo "Attempt to log in"
	printf "%s\n" "$(steam_get_cred STEAM_PASS)" \
		| "$STEAM_STEAMCMD" "+login $(steam_get_cred STEAM_USER)" "+quit"

	if [[ $? == 5 ]]; then
		# 'Steam Guard' is enabled, attempt to get the 'special access code'
		# that (hopefully) was generated.
		einfo "Login failed, attempt to get 'Steam Guard' 'special access code' from email"
		local i imax=5
		for (( i=1; i<=imax; i++ )); do
			# supply 'special access code'
			einfo "'Steam Guard' login attempt $i of $imax"
			printf "%s\n" "$(steam_get_cred STEAM_PASS)" \
				| "$STEAM_STEAMCMD" "+set_steam_guard_code $(steam_get_mail)" \
				"+login $(steam_get_cred STEAM_USER)" \
				"+quit" && break

			(( i < 5 )) || die "Unable to log in"
			sleep 10
		done
	fi
}

# @FUNCTION: steam_src_unpack
# @DESCRIPTION:
# Run steam_firstlogin, then use esteamcmd to install the application referred
# to by STEAM_app_id into S.  STEAM_platform can be set to force installing an
# application for a non-native platform.
#
# This function is exported.
steam_src_unpack() {
	if [[ -z $STEAM_app_id ]]; then
		die "STEAM_app_id is not set, $FUNCNAME cannot be used"
	fi

	local cmd_platform=
	[[ -n $STEAM_platform ]] && cmd_platform="+@sSteamCmdForcePlatformType ${STEAM_platform}"

	# This attempts to immitate the EGIT3_STORE_DIR logic in git-r3.eclass
	local distdir=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}
	: ${STEAM_CACHEDIR=${distdir}/steam-cache}
	if [[ -n $STEAM_CACHEDIR ]]; then
		local fetchdir=$STEAM_CACHEDIR/$STEAM_app_id
		[[ -n $STEAM_platform ]] && fetchdir+="/$STEAM_platform"
	else
		local fetchdir=$S
	fi
	einfo "Download location: $fetchdir"

	if [[ -n $EVCS_OFFLINE ]]; then
		if [[ ! -d $fetchdir ]]; then
			die "EVCS_OFFLINE is set, but fetchdir=$fetchdir does not exist."
		fi
	else
		einfo "Copy steamcmd to ${STEAM_STEAMCMD%/*}"
		cp -rf "${EPREFIX%/}/opt/steamcmd" "${STEAM_STEAMCMD%/*}" || die
		steam_firstlogin

		if [[ ! -d $fetchdir ]]; then
			(
				addwrite /
				mkdir -p "$fetchdir"
			) || die "Unable to create ${fetchdir}"
		fi

		einfo "Install app_id ${STEAM_app_id}"
		(
			addwrite "${fetchdir}"
			esteamcmd \
				"$cmd_platform" \
				"+force_install_dir \"$fetchdir\"" \
				"+app_update ${STEAM_app_id} verify"
		)
	fi

	if [[ -n $STEAM_CACHEDIR ]]; then
		einfo "Copying from cache to \$S"
		cp -fPpR "$fetchdir" "$S" || die
	fi
}
