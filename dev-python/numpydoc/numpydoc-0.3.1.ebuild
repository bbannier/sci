# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
PYTHON_DEPEND="2:2.5"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Sphinx extension to support docstrings in Numpy format"
HOMEPAGE="http://projects.scipy.org/numpy/browser/trunk/doc/sphinxext
	http://pypi.python.org/pypi/numpydoc"
SRC_URI="http://pypi.python.org/packages/source/n/${PN}/${P}.tar.gz"

LICENSE="PYTHON BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="test? ( >=dev-python/sphinx-0.5 )"
RDEPEND=">=dev-python/sphinx-0.5"

src_test() {
	testing() {
		PYTHONPATH="build-${PYTHON_ABI}/abi" "$(PYTHON)" tests/test_docscrape.py
	}
	python_execute_function testing
}
