# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit golang-vcs-snapshot systemd user
KEYWORDS="~amd64"
EGO_PN="github.com/hashicorp/nomad"
NOMAD_WEBUI_ARCHIVE="${P}-webui.tar.xz"
DESCRIPTION="A tool for flexible workload orchestration"
HOMEPAGE="https://www.nomadproject.io"
SRC_URI="https://github.com/hashicorp/nomad/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="MPL-2.0 Apache-2.0 BSD BSD-2 CC0-1.0 ISC MIT"
IUSE="webui"

RESTRICT="test"

DEPEND="dev-go/gox
	>=dev-lang/go-1.11:=
	>=dev-go/go-tools-0_pre20160121"
RDEPEND=""

src_unpack() {
	golang-vcs-snapshot_src_unpack
	if use webui; then
		# The webui assets build has numerous nodejs dependencies,
		# see https://github.com/hashicorp/nomad/blob/master/ui/README.md
		pushd "${S}/src/${EGO_PN}" >/dev/null || die
		unpack "${NOMAD_WEBUI_ARCHIVE}"
		popd >/dev/null
	fi
}

src_prepare() {
	default
	sed -e 's:go get -u -v $(GOTOOLS)::' \
		-e 's:vendorfmt dev-build:dev-build:' \
		-i "src/${EGO_PN}/GNUmakefile" || die
}

pkg_setup() {
	enewgroup nomad
	enewuser nomad -1 -1 /var/lib/${PN} nomad
}

src_compile() {
	mkdir bin || die
	export -n GOCACHE XDG_CACHE_HOME #678970
	export GOBIN=${S}/bin GOPATH=${S}
	cd src/${EGO_PN} || die
	emake pkg/linux_amd64/nomad
}

src_install() {
	dodoc src/${EGO_PN}/{CHANGELOG.md,README.md}
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotated" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	keepdir /etc/${PN}.d
	insinto /etc/${PN}.d
	doins "${FILESDIR}/"*.json.example

	keepdir /var/log/${PN}
	fowners ${PN}:${PN} /var/log/${PN}

	dobin src/${EGO_PN}/pkg/linux_amd64/${PN}
}
