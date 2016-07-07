# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="git://github.com/linode/longview.git"

inherit eutils git-2

DESCRIPTION="Linode Longview"
HOMEPAGE="https://www.linode.com/longview/"
LICENSE="Artistic GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="mysql"

DEPEND=""
RDEPEND="
	app-portage/eix
	dev-perl/IO-Socket-INET6
	dev-perl/JSON
	dev-perl/Log-LogLite
	dev-perl/libwww-perl[ssl]
	dev-perl/Linux-Distribution
	dev-perl/Try-Tiny
	dev-perl/DBI
	mysql? (
		dev-perl/DBD-mysql
	)
"

src_install(){
	insinto /opt/linode/longview
	doins -r Linode
	dodir /opt/linode/longview/Linode/Longview/DataGetter/Packages
	insinto /opt/linode/longview/Linode/Longview/DataGetter/Packages
	doins Extras/Modules/Packages/Gentoo.pm
	fperms +x /opt/linode/longview/Linode/Longview.pl
	keepdir /etc/linode
	dodir /etc/linode/longview.d
	insinto /etc/linode/longview.d
	doins Extras/conf/*.conf
	pushd "${D}" >/dev/null
	fperms o-o etc/linode/longview.d/*.conf
	popd >/dev/null
	newinitd "${FILESDIR}"/longview.openrc longview
}

pkg_postinst(){
	elog "You should now start Longview and enter the API Key provided by the Linode Manager."
	elog "You can do so with the following command:"
	elog
	elog "/etc/init.d/longview start"
	elog
	elog "You'll also want to add Longview to the default runlevel:"
	elog
	elog "rc-update add longview default"
	elog
	elog "If you have any questions about using Longview, please open a support"
	elog "ticket from within the Linode Manager."
}
