# By eroen, 2014
# Distributed under the terms of the ISC licence
# $Header: $

EAPI=5

inherit cdrom

MY_PV=R${PV}

DESCRIPTION="High-level language and interactive environment"
HOMEPAGE="http://www.mathworks.com/products/matlab/"
SRC_URI=""

LICENSE="MATLAB"
RESTRICT="bindist"
SLOT=${MY_PV}
KEYWORDS="-* ~amd64"
IUSE=""

HDEPEND="app-admin/chrpath"
LIBDEPEND=""
DEPEND="${LIBDEPEND}"
RDEPEND="${LIBDEPEND}"
[[ ${EAPI} == *-hdepend ]] || DEPEND+=" ${HDEPEND}"

S=${WORKDIR}
MY_PREFIX=/opt/${P}
INSTALL_KEY_VAR=MATLAB_${MY_PV}_FILE_INSTALLATION_KEY

QA_PRESTRIPPED="${MY_PREFIX#/}/.*"
QA_TEXTRELS="${MY_PREFIX#/}/bin/glnxa64/*"
QA_FLAGS_IGNORED="${MY_PREFIX#/}/.*"

pkg_pretend() {
	if [[ $MERGE_TYPE != binary ]] && [[ -z ${!INSTALL_KEY_VAR} ]]; then
		eerror "You need to set ${INSTALL_KEY_VAR} to your MATLAB ${MY_PV}"
		eerror "File Installation Key, eg. by adding"
		eerror "    ${INSTALL_KEY_VAR}=\"12345-67890-12345-67890\""
		eerror "to your make.conf ."
		eerror
		die
	fi
}

src_unpack() {
	CDROM_NAME="MATLAB ${MY_PV}_UNIX dvd" cdrom_get_cds version.txt

	# I can't find any version-specific filenames at all :(
	local DISK_PV=$(head -n 1 "${CDROM_ROOT}"/version.txt)
	if [[ ${DISK_PV} != ${MY_PV} ]]; then
		eerror "Incorrect disk found at ${CDROM_ROOT}."
		eerror "Expected version: ${MY_PV}"
		eerror "Found version:    ${DISK_PV}"
		eerror
		die
	fi
}

src_configure() {
	sed -e '/^# destinationFolder=/a destinationFolder='"${ED%/}${MY_PREFIX}" \
		-e '/^# fileInstallationKey=/afileInstallationKey='"${!INSTALL_KEY_VAR}" \
		-e '/^# agreeToLicense=/a agreeToLicense=yes' \
		-e '/^# mode=/a mode=silent' \
		-e '/^# automatedModeTimeout=/a automatedModeTimeout=0' \
		-e '/^#product.MATLAB$/a product.MATLAB' \
		< "${CDROM_ROOT}"/installer_input.txt \
		> "${T}"/installer_input.txt \
		|| die
}

src_install() {
	"${CDROM_ROOT}"/install \
		-inputFile "${T}"/installer_input.txt \
		-tmpdir "${T}" \
		-verbose \
		|| die
	find "${ED%/}${MY_PREFIX}"/bin/glnxa64 -type f -name '*.so*' -execdir chrpath -d {} + || die

	# User should be able to add a licence.
	dodir "${MY_PREFIX}"/licences
	fperms 1777 "${MY_PREFIX}"/licences
}

pkg_postinst() {
	:
	# x11-misc/wmname wmname LG3D
	# first startup, key file/activation
}
