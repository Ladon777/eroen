# By eroen, 2013
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="Blender NIF plugin"
HOMEPAGE="http://niftools.sourceforge.net/wiki/NifTools"
SRC_URI="mirror://sourceforge/niftools/${PN}/2.5.x/2.5.09/${P}.77b0815.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

HDEPEND=""
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}
	>=dev-python/pyffi-2.2.0
	>=media-gfx/blender-2.62"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

src_unpack() {
	mkdir "${S}"
	cd "${S}" || die
	default
}

src_install() {
	insinto /usr/share/blender/scripts/mesh
	doins scripts/mesh/mesh_niftools_weightsquash.py \
		scripts/mesh/mesh_niftools_hull.py \
		scripts/mesh/mesh_niftools_morphcopy.py

	insinto /usr/share/blender/scripts/import
	doins scripts/import/import_nif.py
	insinto /usr/share/blender/scripts
	doins scripts/import/import_nif.py
	insinto  /usr/share/blender/scripts/export
	doins scripts/export/export_nif.py
	insinto /usr/share/blender/scripts
	doins scripts/export/export_nif.py

	insinto /usr/share/blender/scripts/object
	doins scripts/object/object_niftools_set_bone_priority.py \
		scripts/object/object_niftools_save_bone_pose.py \
		scripts/object/object_niftools_load_bone_pose.py
	insinto /usr/share/blender/scripts/bpymodules
	doins scripts/bpymodules/nif_common.py \
		scripts/bpymodules/nif_test.py
	default
}
