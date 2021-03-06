# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools-utils

DESCRIPTION="software package for algebraic, geometric and combinatorial problems"
HOMEPAGE="http://www.4ti2.de"
SRC_URI="http://4ti2.de/version_${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="static-libs"

DEPEND="sci-mathematics/glpk[gmp]
	dev-libs/gmp[-nocxx]"
RDEPEND="${DEPEND}"
