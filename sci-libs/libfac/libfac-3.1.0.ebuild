# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils
DESCRIPTION="libfac is an extension of Singular-factory to finite fields"

HOMEPAGE="ftp://www.mathematik.uni-kl.de/pub/Math/Singular/Libfac/"

SRC_URI="ftp://www.mathematik.uni-kl.de/pub/Math/Singular/Libfac/libfac-3-1-0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="singular"

DEPEND="singular? ( sci-libs/factory[singular] )
		!singular? ( sci-libs/factory[-singular] )"

RDEPEND="${DEPEND}"

S="${WORKDIR}/libfac"

src_compile() {
	econf --prefix="${D}/usr" \
		$(use_with singular Singular) ||  die "econf failed"

	emake all || die "make failed"
}

src_install() {
	emake install || die "Install failed"
}