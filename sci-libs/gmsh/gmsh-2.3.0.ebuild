# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit eutils multilib

DESCRIPTION="A three-dimensional finite element mesh generator with built-in pre- and post-processing facilities."
HOMEPAGE="http://www.geuz.org/gmsh/"
SRC_URI="http://www.geuz.org/gmsh/src/${P}-source.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="chaco cgns doc examples jpeg metis opencascade png zlib X"

RDEPEND="sci-libs/gsl
	x11-libs/fltk
	cgns? ( sci-libs/cgnslib )
	jpeg? ( media-libs/jpeg )
	opencascade? ( sci-libs/opencascade )
	png? ( media-libs/libpng )
	zlib? ( sys-libs/zlib )"

DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}.patch

	if use cgns && built_with_use sci-libs/cgnslib hdf5; then
		epatch "${FILESDIR}"/${P}_hdf5.patch
	fi
}

src_compile() {
	local myconf=""
	use opencascade && myconf="${myconf} --with-occ-prefix=$CASROOT/lin"

	# As for now, the MED integration doesnot compile
	myconf="${myconf} --disable-med"

	econf ${myconf} \
		$(use_enable X gui) \
		$(use_enable cgns) \
		$(use_enable jpeg) \
		$(use_enable metis) \
		$(use_enable opencascade occ) \
		$(use_enable png) \
		$(use_enable chaco) \
		$(use_enable zlib)

	emake -j1 || die "emake failed"

	if use doc ; then
		cd doc/texinfo
		emake pdf || die "could not build documentation"
	fi
}

src_install() {
	einstall || die "could not install"
	dodoc README doc/CREDITS.txt

	if use doc ; then
		dodoc doc/{FAQ.txt,README.*} doc/texinfo/*.pdf
	fi

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r demos tutorial || die "failed to install examples"
	fi
}