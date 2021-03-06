# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Tidal harmonics database for libtcd."
HOMEPAGE="http://www.flaterco.com/xtide/"

MY_P="${P/-free-/-}"

SRC_URI="ftp://ftp.flaterco.com/xtide/${MY_P}-free.tcd.bz2"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/share/"${PN}"
	doins "${WORKDIR}/${MY_P}"-free.tcd
}
