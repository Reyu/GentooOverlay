EAPI=5

inherit unpacker

DESCRIPTION="Provides the tools and resources for developers and manufacturers to easily add native NDI support to their video products"
HOMEPAGE="https://github.com/Palakis/obs-ndi/releases/tag/4.5.3"
SRC_URI="https://github.com/Palakis/obs-ndi/releases/download/4.5.3/libndi3_3.5.1-1_amd64.deb"

SLOT="0"
LICENSE="GPL2"
KEYWORDS="amd64"

RDEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack_deb ${A}
	rm ${S}/_gpgorigin
}

src_install() {
	cp -R "${S}/usr" "${D}/" || die "Install failed!"
}
