# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libtomcrypt/Attic/libtomcrypt-1.17-r6.ebuild,v 1.3 2012/04/23 18:04:57 pacho dead $

EAPI="2"

inherit flag-o-matic multilib toolchain-funcs

DESCRIPTION="modular and portable cryptographic toolkit"
HOMEPAGE="http://www.libtom.org/LibTomCrypt/"
SRC_URI="https://github.com/libtom/libtomcrypt/releases/download/${PV}/crypt-${PV}.tar.bz2"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

DEPEND="${RDEPEND}
	doc? ( virtual/latex-base app-text/ghostscript-gpl )"

src_prepare() {
	use doc || sed -i '/^install:/s:docs::' makefile
}

src_test() {
	# Tests don't compile
	true
}

src_install() {
	emake -f makefile.shared DESTDIR="${D}" install ||\
		die "emake install failed"
	dodoc TODO changes || die "dodoc failed"
	if use doc ; then
		dodoc doc/* || die "dodoc failed"
		docinto notes ; dodoc notes/* || die "dodoc failed"
		docinto demos ; dodoc demos/* || die "dodoc failed"
	fi
}
