# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="XTide provides tide and current predictions in a wide variety of formats."
HOMEPAGE="http://www.flaterco.com/xtide/"
SRC_URI="ftp://ftp.flaterco.com/xtide/${P}.tar.bz2"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=">=sci-geosciences/libtcd-2.2.3"
RDEPEND="${DEPEND}"

src_install() {
	dobin xtide tide xttpd
	doman *.[18]
	tcd_paths=`find /usr/share/harmonics-dwf-free* -name '*.tcd'`
	for t in ${tcd_paths}; do
		echo -n ${t} >> xtide.conf
		echo -n ':' >> xtide.conf
	done
	insinto /etc
	doins xtide.conf
}
