# By eroen, 2015
# Distributed under the terms of the ISC licence
# $Header: $

#
# Original Author: eroen
# Purpose: Provide convenience functions for packaging software obtained from
#     Humble Bundle
#

EXPORT_FUNCTIONS pkg_nofetch

humblebundle_pkg_nofetch() {
	einfo "Before installing $PN you need to obtain"
	einfo "    $A"
	if [[ -n $HOMEPAGE ]]; then
		einfo "from $HOMEPAGE or https://www.humblebundle.com"
	else
		einfo "from https://www.humblebundle.com"
	fi
	einfo "and place it in"
	einfo "    $DISTDIR"
}
