EAPI=5

inherit unpacker

DESCRIPTION="The Bridge is an application that runs on your computer in the background and seamlessly encrypts and decrypts your mail as it enters and leaves your computer."
HOMEPAGE="https://protonmail.com/bridge"
SRC_URI="https://protonmail.com/download/${PN}_${PV}-1_amd64.deb"

SLOT="0"
LICENSE="MIT"
KEYWORDS="amd64"

RDEPEND="
	app-crypt/libsecret
	dev-qt/qtmultimedia
	gnome-keyring
	media-fonts/dejavu"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack_deb ${A}
	rm ${S}/_gpgorigin
}

src_install() {
	cp -R "${S}/usr" "${D}/" || die "Install failed!"
}
