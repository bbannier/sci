# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

PYTHON_DEPEND="python? 2:2.6"

inherit distutils eutils flag-o-matic toolchain-funcs versionator python qt4 cmake-utils

MAIN_PV=$(get_major_version)
MAJOR_PV=$(get_version_component_range 1-2)
MY_P="ParaView-${PV}"

DESCRIPTION="ParaView is a powerful scientific data visualization application"
HOMEPAGE="http://www.paraview.org"
SRC_URI="http://www.paraview.org/files/v3.8/${MY_P}.tar.gz"
RESTRICT="mirror"

LICENSE="paraview GPL-2"
KEYWORDS="~x86 ~amd64"
SLOT="0"
IUSE="mpi +python doc examples +gui plugins adaptive streaming cg mysql -coprocessing"
RDEPEND="sci-libs/hdf5[mpi=]
	mpi? ( virtual/mpi[cxx,romio] )
	gui? ( x11-libs/qt-gui:4
			x11-libs/qt-qt3support:4
			x11-libs/qt-opengl:4
			x11-libs/qt-assistant:4
			x11-libs/qt-sql:4 )
	adaptive? ( x11-libs/qt-gui:4
			x11-libs/qt-qt3support:4
			x11-libs/qt-opengl:4
			x11-libs/qt-assistant:4 )
	mysql? ( virtual/mysql )
	coprocessing? ( plugins? ( x11-libs/qt-gui:4 ) )
	dev-libs/libxml2
	media-libs/libpng
	media-libs/jpeg
	media-libs/tiff
	dev-libs/expat
	sys-libs/zlib
	media-libs/freetype
	>=app-admin/eselect-opengl-1.0.6-r1
	virtual/opengl
	sci-libs/netcdf
	x11-libs/libXmu"

DEPEND="${RDEPEND}
		boost? (  >=dev-libs/boost-1.40.0 )
		doc? ( app-doc/doxygen )
		>=dev-util/cmake-2.6.4"

PVLIBDIR="$(get_libdir)/${PN}-${MAJOR_PV}"
S="${WORKDIR}"/${MY_P}

pkg_setup() {
	use python && python_set_active_version 2
}

src_prepare() {
	# gcc header fix
	epatch "${FILESDIR}"/${P}-xdmf-cstring.patch
	# disable automatic byte compiling that act directly on the live system
	epatch "${FILESDIR}"/${P}-xdmf-bc.patch
	# respect lib64
	# http://paraview.org/gitweb?p=ParaView.git;a=commitdiff;h=07ba5364f3ab16d33e7ae7c67f64c4b25e2de11f
	epatch "${FILESDIR}"/${P}-installpath.patch
	# pointsprite example was always built
	# http://paraview.org/gitweb?p=ParaView.git;a=commitdiff;h=c9af0d884532cbe472993d19a2ef6327aa9be5d8
	epatch "${FILESDIR}"/${P}-pointsprite-example.patch
	# Install properly pointspritedemo without duplicate DESTDIR
	epatch "${FILESDIR}"/${P}-pointsprite-example-install.patch
	# mpi + hdf5 fix
	epatch "${FILESDIR}"/${P}-h5part.patch

	# prevent the installation of duplicates of QT libraries.
	sed -i "s:SET(_install_qt_libs ON):SET(_install_qt_libs OFF):g" \
		Applications/ParaView/CMakeLists.txt || die "sed failed"

	if use amd64; then
		sed -i "s:/usr/lib:/usr/lib64:g" \
			Utilities/Xdmf2/libsrc/CMakeLists.txt || die "sed failed"
	fi

	cd VTK
	epatch "${FILESDIR}"/vtk-5.6.0-cg-path.patch
	epatch "${FILESDIR}"/vtk-5.6.0-libpng14.patch
}

src_configure() {
	mycmakeargs=(
	  -DPV_INSTALL_LIB_DIR="${PVLIBDIR}"
	  -DCMAKE_INSTALL_PREFIX=/usr
	  -DEXPAT_INCLUDE_DIR=/usr/include
	  -DEXPAT_LIBRARY=/usr/$(get_libdir)/libexpat.so
	  -DOPENGL_gl_LIBRARY=/usr/$(get_libdir)/libGL.so
	  -DOPENGL_glu_LIBRARY=/usr/$(get_libdir)/libGLU.so
	  -DCMAKE_SKIP_RPATH=YES
	  -DVTK_USE_RPATH=OFF
	  -DBUILD_SHARED_LIBS=ON
	  -DVTK_USE_SYSTEM_FREETYPE=ON
	  -DVTK_USE_SYSTEM_JPEG=ON
	  -DVTK_USE_SYSTEM_PNG=ON
	  -DVTK_USE_SYSTEM_TIFF=ON
	  -DVTK_USE_SYSTEM_ZLIB=ON
	  -DVTK_USE_SYSTEM_EXPAT=ON
	  -DPARAVIEW_USE_SYSTEM_HDF5=ON
	  -DCMAKE_VERBOSE_MAKEFILE=OFF
	  -DCMAKE_COLOR_MAKEFILE=TRUE
	  -DVTK_USE_SYSTEM_LIBXML2=ON
	  -DVTK_USE_OFFSCREEN=TRUE
	  -DCMAKE_USE_PTHREADS=ON
	  -DBUILD_TESTING=OFF
	  -DVTK_USE_FFMPEG_ENCODER=OFF)

	# use flag triggered options
	mycmakeargs+=(
	  $(cmake-utils_use gui PARAVIEW_BUILD_QT_GUI)
	  $(cmake-utils_use gui VTK_USE_QVTK)
	  $(cmake-utils_use gui VTK_USE_QVTK_QTOPENGL)
	  $(cmake-utils_use mpi PARAVIEW_USE_MPI)
	  $(cmake-utils_use python PARAVIEW_ENABLE_PYTHON)
	  $(cmake-utils_use python XDMF_WRAP_PYTHON)
	  $(cmake-utils_use doc BUILD_DOCUMENTATION)
	  $(cmake-utils_use examples BUILD_EXAMPLES)
	  $(cmake-utils_use cg VTK_USE_CG_SHADERS)
	  $(cmake-utils_use adaptive PARAVIEW_BUILD_AdaptiveParaView)
	  $(cmake-utils_use streaming PARAVIEW_BUILD_StreamingParaView)
	  $(cmake-utils_use mysql XDMF_USE_MYSQL)
	  $(cmake-utils_use coprocessing PARAVIEW_ENABLE_COPROCESSING) )

	if use gui; then
		mycmakeargs+=(-DVTK_INSTALL_QT_DIR=/${PVLIBDIR}/plugins/designer)
	fi

	# the rest of the plugins
	mycmakeargs+=(
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_ClientChartView)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_CosmoFilters)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_H5PartReader)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_Moments)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_PointSprite)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_Prism)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_SLACTools)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_AnalyzeNIfTIReaderWriter)
	  $(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_SurfaceLIC))

	if use python; then
		mycmakeargs+=($(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_pvblot))
	fi

	if use coprocessing; then
		mycmakeargs+=($(cmake-utils_use plugins PARAVIEW_BUILD_PLUGIN_CoProcessingScriptGenerator))
	fi

	# ParaView actually ship hdf5-1.6.2 and uses its API.
	append-flags -DH5_USE_16_API -DH5_USE_16_API_DEFAULT

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# set up the environment
	echo "LDPATH=/usr/${PVLIBDIR}" >> "${T}"/40${PN}
	echo "PYTHONPATH=/usr/${PVLIBDIR}" >> "${T}"/40${PN}
	doenvd "${T}"/40${PN}

#	# this binary does not work and probably should not be installed
#	rm -f "${D}/usr/bin/vtkSMExtractDocumentation" \
#		|| die "Failed to remove vtkSMExtractDocumentation"

	# rename /usr/bin/lproj to /usr/bin/lproj_paraview to avoid
	# a file collision with vtk which installs the same file
	mv "${D}/usr/bin/lproj" "${D}/usr/bin/lproj_paraview"  \
		|| die "Failed to rename /usr/bin/lproj"

	# last but not least lets make a desktop entry
	newicon "${S}"/Applications/ParaView/pvIcon.png paraview.png \
		|| die "Failed to create paraview icon."
	make_desktop_entry paraview "Paraview" paraview \
		|| die "Failed to install Paraview desktop entry"

}

pkg_postinst() {
	# with Qt4.5 there seem to be issues reading data files
	# under certain locales. Setting LC_ALL=C should fix these.
	echo
	elog "If you experience data corruption during parsing of"
	elog "data files with paraview please try setting your"
	elog "locale to LC_ALL=C."
	elog "The binary /usr/bin/lproj has been renamed to"
	elog "/usr/bin/lproj_paraview to avoid a file collision"
	elog "with vtk."
	echo
}
