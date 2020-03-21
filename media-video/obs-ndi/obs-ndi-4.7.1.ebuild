EAPI=5

inherit unpacker

DESCRIPTION="Network A/V in OBS Studio"
HOMEPAGE="https://github.com/Palakis/obs-ndi"
SRC_URI="https://github.com/Palakis/obs-ndi/releases/download/${PV}/${PN}_${PV}-1_amd64.deb"

SLOT="0"
LICENSE="GPL"
KEYWORDS="amd64"

RDEPEND="
	net-libs/libndi"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack_deb ${A}
	rm ${S}/_gpgorigin
}

src_install() {
	cp -R "${S}/usr" "${D}/" || die "Install failed!"
}
