# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs fortran

DESCRIPTION="AMD Core Math Library (ACML) for x86 and amd64 CPUs"
HOMEPAGE="http://developer.amd.com/acml.jsp"

MY_PV=${PV//\./\-}
S=${WORKDIR}

IUSE="openmp ifc doc examples"
KEYWORDS="~amd64 ~x86"

SRC_URI="amd64? ( ifc? ( acml-${MY_PV}-ifort-64bit.tgz )
	   !ifc? ( openmp? ( acml-${MY_PV}-ifort-64bit.tgz )
			  !openmp? ( acml-${MY_PV}-gnu-64bit.tgz ) )
	   openmp?         ( acml-${MY_PV}-ifort-64bit.tgz ) )
		   x86? ( ifc? ( acml-${MY_PV}-ifort-32bit.tgz )
	   !ifc? ( openmp? ( acml-${MY_PV}-ifort-32bit.tgz )
			  !openmp? ( acml-${MY_PV}-gnu-32bit.tgz ) )
	   openmp?         ( acml-${MY_PV}-ifort-32bit.tgz ) )"

RESTRICT="strip fetch"
LICENSE="ACML"
SLOT="0"

DEPEND="app-admin/eselect-blas
	app-admin/eselect-lapack"

RDEPEND="${DEPEND}
	openmp? ( >=dev-lang/ifc-9 )
	doc? ( app-doc/blas-docs app-doc/lapack-docs )"

pkg_nofetch() {
	einfo "Please download the ACML from:"
	einfo "${HOMEPAGE}"
	einfo "and place it in ${DISTDIR}."
	einfo "The previous versions could be found at"
	einfo "http://developer.amd.com/acmlarchive.jsp"
	einfo "SRC=${A} $SRC_URI"
}

pkg_setup() {
	elog "From version 3.5.0 on, ACML no longer supports"
	elog "hardware without SSE/SSE2 instructions. "
	elog "For older 32-bit hardware that does not support SSE/SSE2,"
	elog "you must continue to use an older version (ACML 3.1.0 and ealier)."
	epause
	FORTRAN=ifc
	FORT=ifort
	! use ifc && ! use openmp && FORTRAN=g77 && FORT=gnu
	fortran_pkg_setup
}

src_unpack() {
	unpack ${A}
	(DISTDIR="${S}" unpack contents-acml-*.tgz)
	use openmp || rm -rf ${FORT}*_mp*
	FORTDIRS="$(ls -d ${FORT}*)"
}

src_compile() {
	einfo "Nothing to compile"
	return
}

src_test() {
	for fort in ${FORTDIRS}; do
		einfo "Testing acml for $(basename ${fort})"
		cd "${S}/${fort}/examples"
		for d in . acml_mv; do
			cd "${S}/${fort}/examples/${d}"
			emake \
				ACMLDIR="${S}/${fort}" \
				F77="${FORTRANC}" \
				CC="$(tc-getCC)" \
				CPLUSPLUS="$(tc-getCXX)" \
				|| die "emake test in ${fort}/examples/${d} failed"
			emake clean
		done
	done
}

src_install() {
	# respect acml default install dir (and FHS)
	local instdir="/opt/${PN}${PV}"
	dodir ${instdir}

	for fort in ${FORTDIRS}; do
		# install acml
		use examples || rm -rf "${S}/${fort}"/examples
		cp -pPR "${S}/${fort}" "${D}${instdir}"

		# install profiles
		local acmldir=${instdir}/${fort}
		local libname=${acmldir}/lib/libacml
		local prof=acml-${FORTRANC}
		local extlibs
		local extflags
		if [[ "${fort}" =~ "_mp" ]]; then
			prof="${prof}-openmp"
			extlibs="-lpthread"
			libname="${libname}_mp"
			extflags="${extflags} -openmp"
		fi
		for l in blas lapack; do
			# pkgconfig files
			sed -e "s:@LIBDIR@:$(get_libdir):" \
				-e "s:@PV@:${PV}:" \
				-e "s:@ACMLDIR@:${acmldir}:g" \
				-e "s:@EXTLIBS@:${extlibs}:g" \
				-e "s:@EXTFLAGS@:${extflags}:g" \
				"${FILESDIR}"/${l}.pc.in > ${l}.pc \
				|| die "sed ${l}.pc failed"
			insinto ${acmldir}/lib
			doins ${l}.pc

			# eselect files
			cat > eselect.${l} << EOF
${libname}.so /usr/@LIBDIR@/lib${l}.so.0
${libname}.so /usr/@LIBDIR@/lib${l}.so
${libname}.a /usr/@LIBDIR@/lib${l}.a
${acmldir}/lib/${l}.pc  /usr/@LIBDIR@/pkgconfig/${l}.pc
EOF
			eselect ${l} add $(get_libdir) eselect.${l} ${prof}
		done
	echo "LDPATH=${instdir}/${fort}/lib" > 35acml
	echo "INCLUDE=${instdir}/${fort}/include" >> 35acml
	done

	# paths
	doenvd 35acml

	use doc || rm -rf "${S}"/Doc/acml.pdf "${S}"/Doc/html
	cp -pPR "${S}"/Doc "${D}${instdir}"
}

pkg_postinst() {
	# set acml if none are set yet
	for l in blas lapack; do
		if [[ -z "$(eselect ${l} show)" ]]; then
			local prof=acml-${FORTRANC}
			use openmp && prof="${prof}-openmp"
			eselect ${l} set ${prof}
		fi
	done
	elog "Use 'eselect blas' and 'eselect lapack' to select"
	elog "one of the multiple acml blas and lapack profiles"
}