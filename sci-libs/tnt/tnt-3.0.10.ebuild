# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator

MYP="${PN}_$(replace_all_version_separators '_')"

DESCRIPTION="Template Numerical Toolkit: C++ headers for array and matrices"
HOMEPAGE="http://math.nist.gov/tnt/"
SRC_URI="http://math.nist.gov/tnt/${MYP}.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install() {
	insinto /usr/include
	doins *.h || die
}