# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit autotools distutils eutils flag-o-matic toolchain-funcs versionator python multilib


DESCRIPTION="SALOME : The Open Source Integration Platform for Numerical Simulation. KERNEL Component"
HOMEPAGE="http://www.salome-platform.org"
SRC_URI="http://files.opencascade.com/Salome${PV}/src${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="debug doc mpi opengl openpbs"

RDEPEND="opengl?  ( virtual/opengl )
	mpi?     ( sys-cluster/mpich2 )
	debug?   ( dev-util/cppunit )
	openpbs? ( sys-cluster/torque )
	dev-python/omniorbpy
	>=net-misc/omniORB-4.1.2
	x11-libs/qwt:0
	>=sci-libs/vtk-5.0.0
	>=sci-libs/opencascade-6.2"

# Note that Corba is apparently not optional in this module

DEPEND="${RDEPEND}
	app-doc/doxygen
	media-gfx/graphviz
	dev-libs/boost
	>=dev-python/PyQt-3.13
	>=dev-python/sip-4.1.3
	dev-python/numeric
	dev-python/docutils
	dev-lang/swig
	>=x11-libs/qt-3.3.3
	dev-lang/tk
	dev-lang/tcl
	sci-libs/hdf5"

MODULE_NAME="KERNEL"
MY_S="${WORKDIR}/src${PV}/${MODULE_NAME}_SRC_${PV}"
INSTALL_DIR="/opt/salome-${PV}/${MODULE_NAME}"
KERNEL_ROOT_DIR="/opt/salome-${PV}/${MODULE_NAME}"
export OPENPBS="/usr"

src_unpack() {
	python_version
	distutils_python_version
	ewarn "Python 2.4 is highly recommended for Salome..."

	#Warn about mpi use flag for hdf5
	if built_with_use sci-libs/hdf5 mpi ; then
		ewarn "mpi use flag enabled for sci-libs/hdf5, this may cause the build to fail for salome-kernel"
	fi

	if ! built_with_use sci-libs/vtk python ; then
		die "You must rebuild sci-libs/vtk with python USE flag"
	fi

	unpack ${A}
	cd "${MY_S}"
	epatch "${FILESDIR}"/${P}_openpbs.patch
	epatch "${FILESDIR}"/${P}-Batch_Couple.patch
	epatch "${FILESDIR}"/${P}-omniorb_4.1.patch

	# If Python 2.5 is planned to be used, the following patch must be applied. This, however,
	# needs to be thoroughly tested!
	if version_is_at_least "2.5" "${PYVER}"; then
		epatch "${FILESDIR}"/${P}-pyobject.patch
	fi

	# Fix for mpich2 detection, this is also used by salome-component at least
	epatch "${FILESDIR}"/${P}-mpich2.patch
	# Gcc 4.3 support
	if version_is_at_least "4.3" $(gcc-version) ; then
		epatch "${FILESDIR}"/${P}-gcc-4.3.patch
	fi

	# Correct the Salome version number
	sed -i "s:3.2.5:${PV}:g" configure.ac

	./clean_configure
	./build_configure
}


src_compile() {
	cd "${MY_S}"

	local myconf="--with-tcl=/usr/$(get_libdir)/ --with-tk=/usr/$(get_libdir)/"

	# Compiler and linker flags
	if use amd64 ; then
		append-flags -m64
	fi

	# CXXFLAGS are slightly modified to allow the compilation of
	# salome-kernel with OpenCascade and gcc-4.1.x
	if version_is_at_least "4.1" $(gcc-version) ; then
		append-flags -ffriend-injection -fpermissive
	fi

	# Specifying --without-<flag> for mpi / mpich / openpbs
	# has the same effect as turning it on
	# so we just ommit it if it's not required to turn it off
	if use mpi ; then
		myconf="${myconf} --with-mpi --with-mpich"
	fi
	if use openpbs ; then
		myconf="${myconf} --with-openpbs"
	fi


	# Configuration
	econf --prefix=${INSTALL_DIR} \
	      --docdir=${INSTALL_DIR}/share/doc/salome \
	      --infodir=${INSTALL_DIR}/share/info \
	      --datadir=${INSTALL_DIR}/share/salome \
	      --libdir=${INSTALL_DIR}/$(get_libdir)/salome \
	      --with-python-site=${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages/salome \
	      --with-python-site-exec=${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages/salome \
	      --enable-corba-gen \
	      ${myconf} \
	      $(use_enable debug ) \
	      $(use_enable !debug production ) \
	      $(use_with debug cppunit /usr ) \
	      $(use_with opengl opengl /usr) \
	|| die "configuration failed"

	# Compilation
	emake || die "compilation failed"
}


src_install() {
	cd "${MY_S}"

	# Installation
	emake prefix="${D}/${INSTALL_DIR}" \
	      docdir="${D}/${INSTALL_DIR}/share/doc/salome" \
	      infodir="${D}/${INSTALL_DIR}/share/info" \
	      datadir="${D}/${INSTALL_DIR}/share/salome" \
	      libdir="${D}/${INSTALL_DIR}/$(get_libdir)/salome" \
	      pythondir="${D}/${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages" install \
	      || die "emake install failed"

	if use amd64 ; then
		dosym ${INSTALL_DIR}/lib64 ${INSTALL_DIR}/lib
	fi

	echo "KERNEL_ROOT_DIR=${INSTALL_DIR}" > ./90${P}
	echo "LDPATH=${INSTALL_DIR}/$(get_libdir)/salome" >> ./90${P}
	echo "PATH=${INSTALL_DIR}/bin/salome"   >> ./90${P}
	echo "PYTHONPATH=${INSTALL_DIR}/$(get_libdir)/python${PYVER}/site-packages/salome" >> ./90${P}
	doenvd 90${P}
	if use doc ; then
		dodoc AUTHORS ChangeLog INSTALL NEWS README README.FIRST.txt
	fi

	# Fix an import python module problem
	sed -i 's@import CORBA@from omniORB import CORBA@'	"${D}"/"${INSTALL_DIR}"/bin/salome/runSalome.py

	# Install icon and .desktop for menu entry
	doicon "${FILESDIR}"/${PN}.png
	make_desktop_entry runSalome Salome ${PN}.png "Science;Engineering"
}

pkg_postinst() {

	elog "Run \`env-update && source /etc/profile\`"
	elog "now to set up the correct paths."
	elog ""

	ewarn "note a small change to /etc/hosts may be required"
	ewarn "salome doesn't seem to recognise localhost within the hosts file"
	ewarn "a line such as"
	ewarn "127.0.0.1	name.domain	name"
	ewarn "may be required within /etc/hosts"
	ewarn ""
}
