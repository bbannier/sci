# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
PYTHON_DEPEND="2:2.4"

inherit python distutils

MY_PN=${PN//_/.}
MY_P=${P//_/.}

DESCRIPTION="Aggregated NetCDF handler for Pydap Data Access Protocol server."
HOMEPAGE="http://pydap.org"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="pydap"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-python/setuptools-0.6_rc3"
RDEPEND=">=sci-geosciences/pydap-3.0_rc8
	>=dev-python/pupynere-1.0.8
	>=dev-python/configobj-4.6.0"

S="$WORKDIR/$MY_P"
