# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils fortran flag-o-matic multilib portability mpi

IUSE="crypt pbs fortran xmpi romio examples"

MY_P=${P/-mpi}
S=${WORKDIR}/${MY_P}

DESCRIPTION="the LAM MPI parallel computing environment"
SRC_URI="http://www.lam-mpi.org/download/files/${MY_P}.tar.bz2"
HOMEPAGE="http://www.lam-mpi.org"
DEPEND="pbs? ( sys-cluster/torque )
	$(mpi_imp_deplist)"
RDEPEND="${DEPEND}
	crypt? ( net-misc/openssh )
	!crypt? ( net-misc/netkit-rsh )"

SLOT="6"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
LICENSE="lam-mpi"

src_unpack() {
	local docdir=${D}$(get_mpi_dir)/usr/share/doc/${PF}
	unpack ${A}

	cd "${S}"
	sed -i \
		"s|docdir=\"\$datadir/lam/doc\"|docdir=\"${docdir}\"|" \
		romio/util/romioinstall.in

	sed -i "s|^\(docdir.*= \)\$(datadir)/lam/doc|\1\"${docdir#${D}}\"|" \
		share/memory/{ptmalloc,ptmalloc2,darwin7}/Makefile.am

	epatch "${FILESDIR}"/7.1.2-lam_prog_f77.m4.patch
	epatch "${FILESDIR}"/7.1.2-liblam-use-extra-libs.patch
	epatch "${FILESDIR}"/7.1.4-as-needed.patch
	# Isn't needed yet, but is probably the right place to look.
	# sed -i 's:^\(WRAPPER_EXTRA_LDFLAGS=.*\)":\1 -Wl,--no-as-needed":' configure.in
	eautoreconf
}

pkg_setup() {
	MPI_ESELECT_FILE="eselect.mpi.lam-mpi"
	einfo
	elog "LAM/MPI is now in a maintenance mode. Bug fixes and critical patches"
	elog "are still being applied, but little real new work is happening in"
	elog "LAM/MPI. This is a direct result of the LAM/MPI Team spending the"
	elog "vast majority of their time working on our next-generation MPI"
	elog "implementation, http://www.openmpi.org"
	elog "  ---From the lam-mpi hompage.  Please consider upgrading."
	einfo
	
	# fortran_pkg_setup should -not- be run here.
	mpi_pkg_setup
}

src_compile() {
	if use crypt; then
		mpi_conf_args="${mpi_conf_args} --with-rsh=ssh"
	else
		mpi_conf_args="${mpi_conf_args} --with-rsh=rsh"
	fi

	if ! use pbs; then
		# See: http://www.lam-mpi.org/MailArchives/lam/2006/05/12445.php
		rm -rf "${S}"/share/ssi/boot/tm
	elif has_version "<=sys-cluster/torque-2.1.6"; then
		# Newer versions dropped the conflicting names and can
		# be installed to nice directories.
		append-ldflags -L/usr/$(get_libdir)/pbs/lib
	fi

	# Following the above post to the mailing list, we'll get
	# rid of bproc, globus and slurm as well, none of which are
	# in the current tree.
	rm -rf "${S}"/share/ssi/boot/{bproc,globus,slurm}

	if use fortran; then
		fortran_pkg_setup
		# this is NOT in pkg_setup as it is NOT needed for RDEPEND right away it
		# can be installed after merging from binary, and still have things fine
		mpi_conf_args="${mpi_conf_args} --with-fc=${FORTRANC}"
	else
		mpi_conf_args="${mpi_conf_args} --without-fc"
	fi

	mpi_conf_args="
		$(use_with xmpi trillium) 
		--enable-shared
		--with-threads=posix
		$(use_with romio)
		${mpi_conf_args}"
	mpi_src_compile
}

src_install () {
	mpi_src_install

	# There are a bunch more tex docs we could make and install too,
	# but they are replicated in the pdfs!
	mpi_dodoc README HISTORY VERSION
	mpi_dodoc "${S}"/doc/{user,install}.pdf

	# It's your fault if you install lam-mpi multiple times and keep this
	# flag turned on, there's -a lot- of examples.
	if use examples; then
		cd "${S}"/examples
		mpi_dodir /usr/share/${P}/examples
		find -name README -or -iregex '.*\.[chf][c]?$' >"${T}"/testlist
		while read p; do
			treecopy $p "${D}"/$(get_mpi_dir)/usr/share/${P}/examples ;
		done < "${T}"/testlist
	fi
}