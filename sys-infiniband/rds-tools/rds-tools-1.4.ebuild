# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.4.1"
OFED_SUFFIX="1"

inherit openib

DESCRIPTION="OpenIB userspace rds-tools"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=sys-infiniband/libibverbs-1.1.2"
RDEPEND="${DEPEND}
		!sys-infiniband/openib-userspace"

S="${WORKDIR}/${P}-${OFED_SUFFIX}"

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc README AUTHORS ChangeLog
}
