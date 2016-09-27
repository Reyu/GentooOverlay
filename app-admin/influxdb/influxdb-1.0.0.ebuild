# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit user systemd

DESCRIPTION="Time-Series Data Storage"
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
	enewuser influxdb
	enewgroup influxdb
}

src_unpack() {
    if [ "${A}" != "" ]; then
        unpack ${A}
		mv "${P}-1" "${P}"
    fi
}

src_install() {
	doinitd "${FILESDIR}"/init/*
	dobin "${S}"/usr/bin/*
	dodir "/var/lib/influxdb"
	dodir "/etc/influxdb"
	insinto "/etc/influxdb"
	doins "${S}/etc/influxdb/influxdb.conf"
	doman "${S}"/usr/share/man/man1/*
	if use logrotate; then
		insinto /etc/logrotate.d
		doins "${S}/etc/logrotate.d/influxdb"
	fi
	if use systemd; then
		systemd_dounit "${S}/usr/lib/influxdb/scripts/influxdb.service"
	fi
}

pkg_preinst() {
	if [[ -d "${ROOT}/etc/influxdb" && -f "${ROOT}/etc/influxdb/influxdb.conf" ]]; then
		cp "${ROOT}/etc/influxdb/influxdb.conf" "${D}/etc/influxdb/influxdb.conf"
	fi
}
