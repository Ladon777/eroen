# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit eutils distutils-r1 user

MY_PN="Radicale"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A simple CalDAV calendar server"
HOMEPAGE="http://www.radicale.org/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND=">=dev-python/vobject-0.9.5[$PYTHON_USEDEP]"
DEPEND="$RDEPEND
	dev-python/setuptools[$PYTHON_USEDEP]
	test? (
		dev-python/pytest-runner[$PYTHON_USEDEP]
		dev-python/pytest-flake8[$PYTHON_USEDEP]
		dev-python/pytest-cov[$PYTHON_USEDEP]
		dev-python/pytest-isort[$PYTHON_USEDEP]
		)"

S=${WORKDIR}/${MY_P}

RDIR=/var/lib/radicale
LDIR=/var/log/radicale

pkg_setup() {
	enewgroup radicale
	enewuser radicale -1 -1 ${RDIR} radicale
}

#python_prepare() {
#	# no python2 compatibility
#	if ! python_is_python3; then
#		sed -e '2i# coding=utf-8' \
#			-i setup.py || die
#	fi
#}

python_test() {
	esetup.py test || die
}

python_install_all() {
	rm README* || die

	# init file
	newinitd "${FILESDIR}"/radicale.init.d radicale

	# directories
	diropts -m0750
	dodir ${RDIR}
	fowners radicale:radicale ${RDIR}
	diropts -m0755
	dodir ${LDIR}
	fowners radicale:radicale ${LDIR}

	# config file
	insinto /etc/${PN}
	doins config logging

	# fcgi and wsgi files
	exeinto /usr/share/${PN}
	doexe radicale.wsgi
	doexe radicale.fcgi

	distutils-r1_python_install_all
}

pkg_postinst() {
	einfo "A sample WSGI script has been put into ${ROOT}usr/share/${PN}."
	einfo "You will also find there an example FastCGI script."

	einfo "Radicale has features that depend on external libraries."
	einfo "Please install"
	optfeature "htpasswd auth" "dev-python/passlib dev-python/bcrypt"
	optfeature "FastCGI mode" "dev-python/flipflop"
}
