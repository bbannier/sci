# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils autotools

DESCRIPTION="Simulation software to model electromagnetic systems."
HOMEPAGE="http://ab-initio.mit.edu/meep/"
SRC_URI="http://ab-initio.mit.edu/meep/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="mpi hdf5 guile doc examples"

DEPEND="sci-libs/fftw
	sci-libs/gsl
	sci-physics/harminv
	guile? ( >=sci-libs/libctl-3.0 )
	hdf5? ( sci-libs/hdf5 )
	mpi? ( virtual/mpi )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# --enable-shared gave text realloc on amd64
	# autoreconf with latest which seems ok.
	sed -i \
		-e 's/SHARED(no)/SHARED(yes)/' \
		configure.ac || die "sed failed"
	# eautoreconf gives errors
	autoreconf -fi || die "autoreconf failed"
}

src_compile() {
	econf \
		$(use_with mpi) \
		$(use_with hdf5) \
		$(use_with guile libctl) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR=${D} || die "emake install failed"
	dodoc AUTHORS COPYRIGHT NEWS README TODO
	insinto /usr/share/doc/${PF}
	use doc && doins doc/meep.pdf
	use examples && doins -r examples
}