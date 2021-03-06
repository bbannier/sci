# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/avogadro/avogadro-1.0.1.ebuild,v 1.1 2010/05/21 15:33:28 jlec Exp $

EAPI="3"

PYTHON_DEPEND="python? 2:2.5"

inherit cmake-utils eutils python git

DESCRIPTION="Advanced molecular editor that uses Qt4 and OpenGL"
HOMEPAGE="http://avogadro.sourceforge.net/"
EGIT_REPO_URI="git://github.com/cryos/avogadro.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+glsl python"

RDEPEND=">=sci-chemistry/openbabel-2.2.3
	>=x11-libs/qt-gui-4.5.3:4
	>=x11-libs/qt-opengl-4.5.3:4
	x11-libs/gl2ps
	glsl? ( >=media-libs/glew-1.5.0	)
	python? (
		>=dev-libs/boost-1.35
		>=dev-libs/boost-1.35.0-r5[python]
		dev-python/numpy
		dev-python/sip
	)"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-2.0.9
	>=dev-util/cmake-2.6.2"

pkg_setup() {
	python_set_active_version 2
}

src_configure() {
	local mycmakeargs
	mycmakeargs="${mycmakeargs}
		-DENABLE_THREADGL=FALSE
		-DENABLE_RPATH=OFF
		-DENABLE_UPDATE_CHECKER=OFF
		$(cmake-utils_use_enable glsl GLSL)
		$(cmake-utils_use_enable python PYTHON)"

	cmake-utils_src_configure
}
