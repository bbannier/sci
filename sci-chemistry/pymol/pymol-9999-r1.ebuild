# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

PYTHON_MODNAME="chempy pmg_tk pymol"
APBS_PATCH="090618"

inherit distutils subversion flag-o-matic

ESVN_REPO_URI="https://pymol.svn.sourceforge.net/svnroot/pymol/trunk/pymol"

DESCRIPTION="A Python-extensible molecular graphics system."
HOMEPAGE="http://pymol.sourceforge.net/"
SRC_URI="apbs? ( http://dev.gentooexperimental.org/~jlec/distfiles/apbs_tools.py.${APBS_PATCH}.bz2 )"

LICENSE="PSF-2.2"
IUSE="apbs numpy shaders vmd"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/pmw
		dev-python/numpy
		>=dev-lang/python-2.4[tk]
		media-libs/libpng
		sys-libs/zlib
		virtual/glut
		apbs? ( dev-libs/maloc
				sci-chemistry/apbs
				sci-chemistry/pdb2pqr
		)"
DEPEND="${RDEPEND}"

pkg_setup(){
	python_version
}

src_unpack() {
	use apbs && unpack ${A}
	subversion_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-data-path.patch || die

	# Turn off splash screen.  Please do make a project contribution
	# if you are able though.
	[[ -n ${WANT_SPLASH} ]] || epatch "${FILESDIR}"/nosplash-gentoo.patch

	# Respect CFLAGS
	sed -i \
		-e "s:\(ext_comp_args=\).*:\1[]:g" \
		"${S}"/setup.py

	use shaders && \
		sed \
			-e '/PYMOL_OPENGL_SHADERS/s:^#::g' \
			-i setup.py

	if use apbs; then
		cp -f "${WORKDIR}"/apbs_tools.py.${APBS_PATCH} modules/pmg_tk/startup/apbs_tools.py || die
		sed "s:LIBANDPYTHON:$(python_get_libdir):g" \
			-i modules/pmg_tk/startup/apbs_tools.py || die
	fi

	use vmd && \
		sed \
			-e 's:\] + 0 \* \[:] + 1 * [:g' \
			-e '/contrib\/uiuc\/plugins/s:^#::g' \
			-e '/PYMOL_VMD_PLUGINS/s:^#::g' \
			-i setup.py

	use numpy && \
		sed \
			-e '/PYMOL_NUMPY/s:^#::g' \
			-i setup.py
}

src_configure() {
	:
}

src_install() {
	distutils_src_install

	# These environment variables should not go in the wrapper script, or else
	# it will be impossible to use the PyMOL libraries from Python.
	cat >> "${T}"/20pymol <<- EOF
		PYMOL_PATH=$(python_get_sitedir)/${PN}
		PYMOL_DATA="/usr/share/pymol/data"
		PYMOL_SCRIPTS="/usr/share/pymol/scripts"
	EOF

	use apbs && \
	echo "APBS_PSIZE=$(python_get_sitedir)/pdb2pqr/src/psize.py" >> "${T}"/20pymol

	doenvd "${T}"/20pymol || die "Failed to install env.d file."

	cat >> "${T}"/pymol <<- EOF
	#!/bin/sh
	${python} -O \${PYMOL_PATH}/__init__.py \$*
	EOF

	dobin "${T}"/pymol || die "Failed to install wrapper."

	insinto /usr/share/pymol
	doins -r test data scripts || die "no shared data"

	insinto /usr/share/pymol/examples
	doins -r examples || die "Failed to install docs."

	dodoc DEVELOPERS README || die "Failed to install docs."

	if ! use apbs; then
		rm "${D}"$(python_get_sitedir)/pmg_tk/startup/apbs_tools.py
	fi
}

pkg_postinst(){
	distutils_pkg_postinst

	# The apbs ebuild was just corrected and not bumped #213616
	if use apbs; then
		[ -e /usr/share/apbs-0.5* ] && \
		ewarn "You need to reemerge sci-chemistry/apbs!"
	fi
}