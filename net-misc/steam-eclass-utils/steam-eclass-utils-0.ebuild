# By eroen <eroen-overlay@occam.eroen.eu>, 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6
PYTHON_COMPAT=(python2_7 python3_3 python3_4 python3_5)
PYTHON_REQ_USE="ssl"

# steam.eclass used for $ESTEAM_SCRIPTDIR
inherit steam python-r1

DESCRIPTION="Utilities used by steam.eclass"
HOMEPAGE="http://eroen.eu"
SRC_URI=""
LICENSE="ISC"
S=$WORKDIR

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="steam-guard"

DEPEND=""
RDEPEND="${DEPEND}
	steam-guard? ( $PYTHON_DEPS )"
REQUIRED_USE="steam-guard? ( ${PYTHON_REQUIRED_USE} )"

src_install() {
	if use steam-guard; then
		exeinto "$ESTEAM_SCRIPTDIR"
		doexe "$FILESDIR"/steam-mail.py
		python_replicate_script "$ED/$ESTEAM_SCRIPTDIR"/steam-mail.py
	fi
}
