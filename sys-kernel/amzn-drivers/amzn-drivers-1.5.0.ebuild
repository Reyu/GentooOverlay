# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

if [[ ${PV} == "9999" ]] ; then
    AUTOTOOLS_AUTORECONF="1"
    EGIT_REPO_URI="https://github.com/amzn/${PN}.git"
    inherit git-r3
else
    SRC_URI="https://github.com/amzn/amzn-drivers/archive/ena_linux_${PV}.tar.gz"
    KEYWORDS="~amd64"
fi

inherit flag-o-matic autotools-utils linux-info linux-mod

DESCRIPTION="Elastic Network Adapter (ENA) network adapter for Linux and FreeBSD operating systems"
HOMEPAGE="https://github.com/amzn/amzn-drivers"

LICENSE="GPL-2"
SLOT="0"

S="${WORKDIR}/${PN}-ena_linux_${PV}"

BUILD_TARGETS="clean all"
MODULE_NAMES="ena(:kernel/linux/ena:)"

src_configure() {
    true;
}
