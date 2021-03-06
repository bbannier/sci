# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/octave/octave-2.1.73-r1.ebuild,v 1.2 2006/11/03 15:44:39 markusle Exp $

inherit octave-forge

DESCRIPTION="Parallel execution package for cluster computers."
LICENSE="GPL-2"
HOMEPAGE="http://octave.sourceforge.net/parallel/index.html"
SRC_URI="mirror://sourceforge/octave/${OCT_PKG}.tar.gz"
SLOT="0"

IUSE=""
KEYWORDS="~amd64 ~x86"

PATCHES=("octave-forge-parallel-2.0.0-octave-3.2.patch"
		"octave-forge-parallel-2.0.0-description.patch"
		"octave-forge-parallel-2.0.0-extern.patch")
