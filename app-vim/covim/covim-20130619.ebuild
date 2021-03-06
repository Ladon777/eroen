# By eroen, 2013 - 2016
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5
PYTHON_COMPAT=(python2_7)

#VIM_PLUGIN_VIM_VERSION="7.0"
inherit python-single-r1 vim-plugin git-2

DESCRIPTION="Collaborative Editing for Vim"
HOMEPAGE="https://github.com/FredKSchott/CoVim"
LICENSE="MIT"
IUSE=""
SRC_URI=

EGIT_REPO_URI="git://github.com/FredKSchott/CoVim.git"
if ! [[ ${PV} == 99999999 ]]; then
	KEYWORDS="~amd64"
	EGIT_COMMIT=410a0a1f69c4c52555e6ee95e8b94ec1e8779351
fi

VIM_PLUGIN_HELPFILES="CoVim"
VIM_PLUGIN_HELPTEXT=""
VIM_PLUGIN_HELPURI=""
VIM_PLUGIN_MESSAGES=""

LDEPEND="
	${PYTHON_DEPS}
	dev-python/twisted-core
	app-editors/vim[python,${PYTHON_USEDEP}]"
RDEPEND="${LDEPEND}"

src_prepare() {
	python_fix_shebang plugin/CoVimServer.py
	rm LICENSE
}

src_install() {
	eshopts_push -u failglob
	vim-plugin_src_install
	eshopts_pop
	chmod ugo+x "${D}"/usr/share/vim/vimfiles/plugin/CoVimServer.py || die
}
