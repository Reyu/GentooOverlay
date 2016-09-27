# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit user systemd

DESCRIPTION="Time-Series Data Collector"
HOMEPAGE="https://www.influxdata.com/time-series-platform/${PN}/"
SRC_URI="
	amd64? ( https://dl.influxdata.com/${PN}/releases/${P}_linux_amd64.tar.gz )
	x86?   ( https://dl.influxdata.com/${PN}/releases/${P}_linux_i386.tar.gz )
	arm?   ( https://dl.influxdata.com/${PN}/releases/${P}_linux_armhf.tar.gz )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~x86 ~amd64 ~arm"
IUSE="logrotate systemd"

RDEPEND="logrotate? ( app-admin/logrotate )"

pkg_setup() {
	enewuser ${PN}
	enewgroup ${PN}
}

src_unpack() {
    if [ "${A}" != "" ]; then
        unpack ${A}
		mv "${PN}" "${P}"
    fi
}

src_install() {
	doinitd "${FILESDIR}"/init/*
	dobin "${S}/usr/bin/${PN}"
	dodir "/etc/${PN}"
	insinto "/etc/${PN}"
	doins "${S}/etc/${PN}/${PN}.conf"
	if use logrotate; then
		insinto /etc/logrotate.d
		doins "${S}/etc/logrotate.d/${PN}"
	fi
	if use systemd; then
		systemd_dounit "${S}/usr/lib/${PN}/scripts/${PN}.service"
	fi
}

pkg_preinst() {
	if [[ -d "${ROOT}/etc/${PN}" && -f "${ROOT}/etc/${PN}/${PN}.conf" ]]; then
		cp "${ROOT}/etc/${PN}/${PN}.conf" "${D}/etc/${PN}/${PN}.conf"
	fi
}
