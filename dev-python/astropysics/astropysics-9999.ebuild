# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit bzr distutils

DESCRIPTION="General purpose python library for professional astronomers/astrophysicists"
HOMEPAGE="http://packages.python.org/Astropysics/"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

EBZR_REPO_URI="lp:astropysics"

DEPEND="doc? ( dev-python/sphinx )"
RDEPEND="dev-python/chaco
	dev-python/matplotlib
	dev-python/pyfits
	dev-python/vo
	sci-astronomy/sextractor
	sci-visualization/mayavi
	sci-libs/scipy"

RESTRICT_PYTHON_ABIS="3.*"

src_compile() {
	distutils_src_compile
	if use doc; then
		cd docs
		emake html || die
	fi
}

src_install() {
	distutils_src_install
	if use doc; then
		cd docs/_build
		insinto /usr/share/doc/${PF}
		doins -r html || die
		cd ../..
	fi
}
