# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

FORTRANC="g77 gfortran ifc"

inherit eutils python fortran

DESCRIPTION="An automated data reduction system for crystallography"
HOMEPAGE="http://www.ccp4.ac.uk/xia/"
SRC_URI="${HOMEPAGE}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=sci-chemistry/ccp4-6.1.1-r5
	sci-chemistry/pointless
	sci-chemistry/mosflm
	>=sci-libs/ccp4-libs-6.1.1-r7"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	find . -name '*.bat' | xargs rm || die

	epatch "${FILESDIR}"/${PV}-fix-syntax.patch
}

src_compile() {
	cd "${S}"/${P}/binaries/src
	cp "${FILESDIR}"/Makefile.chef Makefile
	emake  \
		FC="${FORTRANC}" || die
}

src_install() {
	dobin ${P}/binaries/src/{doser,chef,mat2symop,symop2mat} || die

	rm -rf ${P}/binaries ${PN}core-${PV}/Test || die

	insinto /usr/share/ccp4/XIAROOT/
	doins -r * || die

	# Set programs executable
# fperms cannot handle wildcards
	chmod 755 "${D}"/usr/share/ccp4/XIAROOT/${P}/Applications/* || die
	chmod 644 "${D}"/usr/share/ccp4/XIAROOT/${P}/Applications/*.py || die

	cat >> "${T}"/23XIA <<- EOF
	XIA2_HOME=/usr/share/ccp4/XIAROOT

	XIA2CORE_ROOT=/usr/share/ccp4/XIAROOT/xia2core-${PV}
	XIA2_ROOT=/usr/share/ccp4/XIAROOT/xia2-${PV}

	PATH=/usr/share/ccp4/XIAROOT/xia2-${PV}/Applications
	EOF

	doenvd "${T}"/23XIA
}

pkg_postinst() {
	python_mod_optimize /usr/share/ccp4/XIAROOT
}

pkg_postrm() {
	python_mod_cleanup /usr/share/ccp4/XIAROOT
}