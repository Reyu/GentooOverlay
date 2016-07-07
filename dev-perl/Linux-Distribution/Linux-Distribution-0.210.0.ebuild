# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MODULE_AUTHOR=CHORNY
MODULE_VERSION=0.21
PATCHES=( "${FILESDIR}/quotes-in-lsb-release.patch" )
inherit perl-module

DESCRIPTION="Detect on which Linux distribution we are running"

SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=""

SRC_TEST=do
