# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Policy-driven snapshot management and replication tools for ZFS."
HOMEPAGE="https://github.com/jimsalterjrs/sanoid"
SRC_URI="https://github.com/jimsalterjrs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	dosbin sanoid
	dosbin syncoid
	dosbin findoid
	dodir /etc/sainoid
	insinto /etc/sanoid
	doins sanoid.conf
	doins sanoid.defaults.conf
}
