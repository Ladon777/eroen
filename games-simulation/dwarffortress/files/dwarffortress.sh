#!/bin/sh
# Launcher script for running dwarffortress-40.03 on Gentoo
# By eroen, 2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# DF expects to find its resources in the CWD, and it also expects write access
# to some of them. This script sets up a minimal CWD within $DF_DIR by
# symlinking and copying from $DATA_PREFIX, then executes DF.

unset DOHELP
unset DOINSTALL
DFOPTS=""
while [ "0" -lt "${#}" ]; do
	if [ "--help" = "${1}" ] || [ "-h" = "${1}" ]; then
		DOHELP=y
	elif [ "--install" = "${1}" ] || [ "-i" = "${1}" ]; then
		DOINSTALL=y
	elif [ "--" = "${1}" ]; then
		DFOPTS="${DFOPTS} ${*}"
		break
	else
		DFOPTS="${DFOPTS} ${1}"
	fi
	shift
done

if [ -n "${DOHELP}" ]; then
	echo "Usage: ${0} [OPTION] [-- DF_OPTION ...]"
	echo "  -h, --help	Print this message and exit."
	echo "  -i, --install	Only install workdir files to \$HOME, do not launch DF."
	echo "  Unrecognized options and options after '--' are passed on to DF."
	echo
	echo "This launcher script is specific to Gentoo Linux. Please report any"
	echo "issues to the package maintainer."

	exit 0
fi

DF_DIR="@@DF_DIR@@"
DATA_PREFIX="@@DATA_PREFIX@@"
LIBPATH="@@LIBPATH@@"

if ! [ -d "${DF_DIR}" ]; then
	echo "Creating ${DF_DIR} ..."
	mkdir -p "${DF_DIR}"
fi

for item in data data/save; do
	if ! [ -d "${DF_DIR}/${item}" ]; then
		echo "Creating ${item}/ ..."
		mkdir -p "${DF_DIR}/${item}"
	fi
done

#    40.03:
# open("data/announcement/fortressintro", O_RDWR|O_LARGEFILE
# open("data/dipscript/dwarf_liaison", O_RDWR|O_LARGEFILE
# open("data/help/main", O_RDWR|O_LARGEFILE)
# data/init holds user configuration files
# open("data/index", O_RDWR|O_LARGEFILE)
# open("data/movies/last_record.cmv", O_WRONLY|O_CREAT|O_APPEND|O_LARGEFILE, 0666)
for item in data/announcement data/dipscript data/help data/init \
	data/index data/movies; do
	if ! [ -e "${DF_DIR}/${item}" ]; then
		echo "Copying ${item} ..."
		cp -R "${DATA_PREFIX}/${item}" "${DF_DIR}/${item}"
	fi
done

for item in data/art data/initial_movies data/shader.fs data/shader.vs \
	data/sound data/speech raw; do
	if ! [ -e "${DF_DIR}/${item}" ]; then
		echo "Symlinking ${item} ..."
		ln -s "${DATA_PREFIX}/${item}" "${DF_DIR}/${item}"
	fi
done

# Exit early if only installing.
if [ -n "${DOINSTALL}" ]; then
	exit 0
fi

# 40.03: There seems to be an issue with prebuilt libgraphics
if false; then # PRELOAD_LIBZ
	if [ "${LD_LIBRARY_PATH+set}" = "set" ] ; then
		LD_PRELOAD=${LD_PRELOAD}:/lib32/libz.so.1
	else
		LD_PRELOAD=/lib32/libz.so.1
	fi
	export LD_PRELOAD
fi

# Used for system-libgraphics and dfhack
if false; then # SET_LIBPATH
	if [ "${LD_LIBRARY_PATH+set}" = "set" ] ; then
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LIBPATH}
	else
		LD_LIBRARY_PATH=${LIBPATH}
	fi
	export LD_LIBRARY_PATH
fi

cd "${DF_DIR}"
exec "${DATA_PREFIX}"/libs/Dwarf_Fortress ${DFOPTS}
