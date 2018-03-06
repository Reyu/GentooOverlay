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

inherit flag-o-matic linux-info linux-mod autotools-utils

DESCRIPTION="Elastic Network Adapter (ENA) network adapter for Linux and FreeBSD operating systems"
HOMEPAGE="https://github.com/amzn/amzn-drivers"

LICENSE="GPL-2"
SLOT="0"
IUSE="debug"

COMMON_DEPEND=""

DEPEND="${COMMON_DEPEND}"

RDEPEND="${COMMON_DEPEND}"

AT_M4DIR="config"
AUTOTOOLS_IN_SOURCE_BUILD="1"
DOCS=( AUTHORS DISCLAIMER )

# src_install() {
# 	autotools-utils_src_install INSTALL_MOD_PATH="${INSTALL_MOD_PATH:-$EROOT}"
# }
