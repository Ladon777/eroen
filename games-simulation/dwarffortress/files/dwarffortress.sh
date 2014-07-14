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

if [ "--help" == "${1}" ] || [ "-h" == "${1}" ]; then
	echo "Usage: ${0} [OPTION]"
	echo "  -h, --help	Print this message and exit."
	echo "  -i, --install	Only install workdir files to \$HOME, do not launch DF."
	echo
	echo "This launcher script is specific to Gentoo Linux."
	echo "Please report any issues to the package maintainer."

	exit 0
fi

DF_DIR="@@DF_DIR@@"
DATA_PREFIX="@@DATA_PREFIX@@"

if ! [ -d "${DF_DIR}" ]; then
	echo "Creating and populating ${DF_DIR} ..."
	mkdir -p "${DF_DIR}"

	for item in data data/save; do
		echo "Creating ${item}/ ..."
		mkdir -p "${DF_DIR}/${item}"
	done

	#    40.03:
	# open("data/announcement/fortressintro", O_RDWR|O_LARGEFILE
	# open("data/dipscript/dwarf_liaison", O_RDWR|O_LARGEFILE
	# open("data/help/main", O_RDWR|O_LARGEFILE)
	# data/init holds user configuration files
	# open("data/index", O_RDWR|O_LARGEFILE)
	# open("data/movies/last_record.cmv", O_WRONLY|O_CREAT|O_APPEND|O_LARGEFILE, 0666)
	for item in data/announcement data/dipscript data/help data/init data/index data/movies; do
		echo "Copying ${item} ..."
		cp -R "${DATA_PREFIX}/${item}" "${DF_DIR}/${item}"
	done

	for item in data/{art,initial_movies,shader.fs,shader.vs,sound,speech} raw; do
		echo "Symlinking ${item} ..."
		ln -s "${DATA_PREFIX}/${item}" "${DF_DIR}/${item}"
	done

	echo "${DF_DIR} populated, launching..."
else
	echo "${DF_DIR} already exists, not populating..."
fi

# Exit early if only installing.
if [ "--install" == "${1}" ] || [ "-i" == "${1}" ]; then
	exit 0
fi

# 40.03: There seems to be an issue with prebuilt libgraphics
if false; then # PRELOAD_LIBZ
	export LD_PRELOAD=${LD_PRELOAD}:/lib32/libz.so.1
fi

cd "${DF_DIR}"
exec "${DATA_PREFIX}"/libs/Dwarf_Fortress
