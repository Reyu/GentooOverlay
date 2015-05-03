# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="5"
SLOT="0"

Description="Simple bash script to allow for control of pulseaudio without alsautils"
HOMEPAGE="http://github.com/graysky2/pulseaudio-ctl.git"
LICENSE="MIT"

if [ ${PV} == "9999" ] ; then
	inherit git-2 linux-mod
	EGIT_REPO_URI="http://github.com/graysky2/${PN}.git"
else
	inherit eutils versionator
	MY_PV=$(replace_version_separator 3 '-')
	SRC_URI="https://codeload.github.com/graysky2/${PN}/tar.gz/v${PV}"
fi

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

COMMON_DEPEND="media-sound/pulseaudio"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_unpack() {
	tar xzf ../distdir/$A
}
