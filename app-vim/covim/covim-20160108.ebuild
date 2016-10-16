# By eroen <eroen-overlay@occam.eroen.eu>, 2013 - 2016
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

EAPI=6
PYTHON_COMPAT=(python2_7)

inherit eutils python-r1 vim-plugin

DESCRIPTION="Collaborative Editing for Vim"
HOMEPAGE="https://github.com/FredKSchott/CoVim"
LICENSE="MIT"
IUSE=""

if [[ ${PV} == 99999999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="git://github.com/FredKSchott/CoVim.git"
else
	KEYWORDS="~amd64"
	#EGIT_COMMIT=
	inherit vcs-snapshot
	SRC_URI="https://github.com/FredKSchott/CoVim/archive/181ed37d6c2778f26d29775009d1e657c6c701a9.tar.gz -> $P.tar.gz"
fi

RDEPEND="${PYTHON_DEPS}
	dev-python/twisted-core[${PYTHON_USEDEP}]
	app-editors/vim[python,${PYTHON_USEDEP}]"

VIM_PLUGIN_HELPFILES="CoVim"

src_prepare() {
	default
	rm -f LICENSE || die
}

src_install() {
	eshopts_push -u failglob
	vim-plugin_src_install
	eshopts_pop
	python_replicate_script "${ED}"/usr/share/vim/vimfiles/plugin/CoVimServer.py
}
