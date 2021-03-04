EAPI=7

DESCRIPTION="NordVPN Linux Cilent"
MY_PN="nordvpn"
HOMEPAGE="https://nordvpn.com"
SRC_URI="
	amd64? ( https://repo.nordvpn.com/deb/${MY_PN}/debian/pool/main/${MY_PN}_${PV}_amd64.deb )
	x86?   ( https://repo.nordvpn.com/deb/${MY_PN}/debian/pool/main/${MY_PN}_${PV}_i386.deb )
	arm64? ( https://repo.nordvpn.com/deb/${MY_PN}/debian/pool/main/${MY_PN}_${PV}_arm64.deb )"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"
IUSE="+bash-completion systemd zsh-completion"
QA_PREBUILT="/usr/*bin/${MY_PN}* /var/lib/${MY_PN}/*"

S=${WORKDIR}/

RDEPEND="
	acct-group/nordvpn
	app-misc/ca-certificates
	dev-libs/libxslt
	net-firewall/ipset
	net-firewall/iptables
	sys-apps/iproute2
	sys-process/procps"

src_install() {
	unpack ${S}/data.tar.xz

	doinitd ${S}/etc/init.d/nordvpn
	dobin ${S}/usr/bin/nordvpn
	dosbin ${S}/usr/sbin/nordvpnd

	unpack ${S}/usr/share/doc/nordvpn/changelog.gz
	unpack ${S}/usr/share/man/man1/nordvpn.1.gz
	dodoc ${S}/changelog
	doman ${S}/nordvpn.1

	insinto /var/lib/${MY_PN}/data
	doins -r ${S}/var/lib/nordvpn/data/
	into /var/lib/${MY_PN}
	doins ${S}/var/lib/nordvpn/icon.svg
	exeinto /var/lib/${MY_PN}
	doexe ${S}/var/lib/nordvpn/openvpn

	use bash-completion && {
		exeinto /usr/share/bash-completion/completions
		doexe usr/share/bash-completion/completions/nordvpn
	}

	use zsh-completion && {
		exeinto /usr/share/zsh/functions/Completion/Unix
		doexe usr/share/zsh/functions/Completion/Unix/_nordvpn_auto_complete
	}

	use systemd && {
		insinto /usr/lib/systemd
		doins -r ${S}/usr/lib/systemd
		insinto /usr/lib/tmpfiles.d
		doins -r ${S}/usr/lib/tmpfiles.d
	}
}

pkg_postinst() {
	elog "NordVPN for Linux successfully installed!"
	elog "To allow users to use the application run 'usermod -aG nordvpn user'."
	elog ""
	elog "To get started, type 'nordvpn login' and enter your NordVPN account details."
	elog "Then type 'nordvpn connect' and you’re all set!"
	elog ""
	elog "If you need help using the app, use the command 'nordvpn --help'."
}
