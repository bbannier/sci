# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit fortran base toolchain-funcs versionator

MY_PV="$(get_version_component_range 1-2)"

DESCRIPTION="Macromolecular crystallographic refinement program"
HOMEPAGE="http://www.ysbl.york.ac.uk/~garib/refmac/"
#SRC_URI="${HOMEPAGE}data/refmac_experimental/${PN}_source_v${PV}.tar.gz"
SRC_URI="${HOMEPAGE}data/refmac_experimental/${PN}${MY_PV}_source_v${PV}.tar.gz"

SLOT="0"
LICENSE="ccp4"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="mirror"
RDEPEND="virtual/lapack
	virtual/blas
	>=sci-libs/ccp4-libs-6.1.1-r1"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/${PV}-allow-dynamic-linking.patch
)

src_compile() {
	emake \
		FC=$(tc-getFC) \
		CC=$(tc-getCC) \
		CXX=$(tc-getCXX) \
		COPTIM="${CFLAGS}" \
		FOPTIM="${FFLAGS:- -O2}" \
		VERSION="" \
		XFFLAGS="-fno-second-underscore" \
		LLIBCCP="-lccp4f -lccp4c -lccif -lmmdb -lstdc++" \
		LLIBLAPACK="-llapack -lblas" \
		|| die
}

src_install() {
	for i in refmac libcheck; do
		dobin ${i} || die
	done
	dosym refmac /usr/bin/refmac5 || die
#	dodoc refmac_keywords.pdf || die
}