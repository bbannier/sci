# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit rpm

LICENSE="|| ( GPL-2 BSD-2 )"
SLOT="0"

KEYWORDS="~x86 ~amd64"

DESCRIPTION="OpenFabrics userspace distribution.  An all-inclusive ebuild
alternative to the openib meta-ebuild"

HOMEPAGE="http://www.openfabrics.org/"
SHORT_PV=${PV%\.[^.]}
SRC_URI="http://www.openfabrics.org/builds/ofed-${SHORT_PV}/release/OFED-${PV}.tgz"
MY_P="OFED-${PV}"
S="${WORKDIR}/ofa_user-${PV}"
OSM="${S}/src/userspace/management/osm"

IUSE="ehca ipath cxgb3 opensm dapl srptools qlvnictools tvflash mstflint"

DEPEND=""
PDEPEND="=sys-infiniband/openib-files-${PV}"
RDEPEND="${DEPEND}
		 !sys-infiniband/libibverbs
		 !sys-infiniband/libmthca
		 !sys-infiniband/libipathverbs
		 !sys-infiniband/librdmacm
		 !sys-infiniband/libsdp
		 !sys-infiniband/dapl
		 !sys-infiniband/libehca
		 !sys-infiniband/libibcm
		 !sys-infiniband/libibcommon
		 !sys-infiniband/libibmad
		 !sys-infiniband/libibumad
		 !sys-infiniband/openib-diags
		 !sys-infiniband/openib-osm
		 !sys-infiniband/openib-perf
		 !sys-infiniband/openib-srptools
		 !sys-infiniband/openib"

src_unpack() {
	unpack ${A} || die "unpack failed"
	rpm_unpack ${MY_P}/SRPMS/ofa_user-${PV}-0.src.rpm
	tar xzf ofa_user-${PV}.tgz
}

src_compile() {
	myconf="--with-libibverbs --with-libmthca"
	if use ipath ; then myconf="$myconf --with-libipathverbs"; fi
	if use ehca ; then myconf="$myconf --with-libehca"; fi
	if use cxgb3 ; then myconf="$myconf --with-libcxgb3"; fi
	myconf="$myconf --with-libibcm"
	myconf="$myconf --with-libsdp"
	myconf="$myconf --with-librdmacm"
	myconf="$myconf $(use_with dapl)"
	if use opensm ; then myconf="$myconf --with-management-libs"; fi
	myconf="$myconf $(use_with opensm)"
	myconf="$myconf --with-openib-diags"
	myconf="$myconf --with-perftest"
	myconf="$myconf $(use_with srptools)"
	myconf="$myconf --with-ipoibtools"
	myconf="$myconf $(use_with qlvnictools)"
	myconf="$myconf $(use_with tvflash)"
	myconf="$myconf $(use_with mstflint)"
	myconf="$myconf --with-sdpnetstat"
	#econf ${myconf} || die "configure failed"
	./configure --prefix=/usr --mandir=/usr/share/man \
		--sysconfdir=/etc \
		${myconf} ${EXTRA_ECONF} || die "configure failed"
	emake -j1
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc "${WORKDIR}/${MY_P}/README.txt"
	dodoc "${WORKDIR}/${MY_P}/docs/*"
	if use opensm ; then
		newconfd "${OSM}/scripts/opensm.sysconfig" opensm
		newinitd "${FILESDIR}/opensm.init.d" opensm
		insinto /etc
		doins "${S}/ofed_scripts/opensm.conf"
		dobin "${S}/ofed_scripts/sldd.sh"
	fi
}

pkg_postinst() {
	einfo "To automatically configure the infiniband subnet manager on boot,"
	einfo "edit /etc/opensm.conf and add opensm to your start-up scripts:"
	einfo "\`rc-update add opensm default\`"
}

