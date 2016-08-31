# By eroen, 2015
# Distributed under the terms of the ISC licence
# $Header: $

#
# Original Author: eroen
# Purpose: Simplify generating library version requirements for prebuilt binaries
#

inherit versionator

# http://rpmfind.net/linux/rpm2html/search.php?query=libstdc%2B%2B.so.6%28GLIBCXX_3.4.15%29
### GLIBCXX:
# GLIBCXX_3.4.15
# -> >=sys-devel/gcc-4.6.0[cxx]

get_minver_GLIBCXX() {
	local sym="$1"

	local verlist=(
		"3.4.22"
		"3.4.21 5.1.1"
		"3.4.20 4.9.2"
		"3.4.19 4.8.1"
		"3.4.18 4.8.1"
		"3.4.17 4.7.0"
		"3.4.16 4.6.0"
		"3.4.15 4.6.0"
		"3.4.14 4.5.1"
		"3.4.13 4.4.5"
		)

	if version_is_at_least "${verlist[0]% *}" "$sym"; then
		die "GLIBCXX_$sym is too recent for this eclass"
	fi
	for ver in "${verlist[@]}"; do
		if version_is_at_least "${ver% *}" "$sym"; then
			echo ${ver#* }
			return
		fi
	done

	die "Could not match GLIBCXX_$sym"
}



# http://rpmfind.net/linux/rpm2html/search.php?query=libc.so.6(GLIBC_2.11)
### GLIBC:
# GLIBC_2.18
# -> >=sys-libs/glibc-2.18
