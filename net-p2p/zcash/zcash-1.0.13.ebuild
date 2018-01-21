# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit bash-completion-r1 flag-o-matic systemd user

# depends/packages/bdb.mk (http://www.oracle.com, AGPL-3 license)
BDB_PV="6.2.23"
BDB_PKG="db-${BDB_PV}.tar.gz"
BDB_HASH="47612c8991aa9ac2f6be721267c8d3cdccf5ac83105df8e50809daea24e95dc7"
BDB_URI="https://z.cash/depends-sources/${BDB_PKG}"
BDB_STAMP=".stamp_fetched-bdb-${BDB_PKG}.hash"

# depends/packages/googlemock.mk (https://github.com/google/googlemock, ??? license)
GMOCK_PV="1.7.0"
GMOCK_PKG="googlemock-${GMOCK_PV}.tar.gz"
GMOCK_HASH="3f20b6acb37e5a98e8c4518165711e3e35d47deb6cdb5a4dd4566563b5efd232"
GMOCK_URI="https://github.com/google/googlemock/archive/release-${GMOCK_PV}.tar.gz"
GMOCK_STAMP=".stamp_fetched-googlemock-${GMOCK_PKG}.hash"

# depends/packages/googletest.mk (https://github.com/google/googletest, ??? license)
GTEST_PV="1.7.0"
GTEST_PKG="googletest-${GTEST_PV}.tar.gz"
GTEST_HASH="f73a6546fdf9fce9ff93a5015e0333a8af3062a152a9ad6bcb772c96687016cc"
GTEST_URI="https://github.com/google/googletest/archive/release-${GTEST_PV}.tar.gz"
GTEST_STAMP=".stamp_fetched-googletest-${GTEST_PKG}.hash"

# depends/packages/openssl.mk (https://www.openssl.org, openssl license)
OPENSSL_PV="1.1.0d"
OPENSSL_PKG="openssl-${OPENSSL_PV}.tar.gz"
OPENSSL_HASH="7d5ebb9e89756545c156ff9c13cf2aa6214193b010a468a3bc789c3c28fe60df"
OPENSSL_URI="https://www.openssl.org/source/${OPENSSL_PKG}"
OPENSSL_STAMP=".stamp_fetched-openssl-${OPENSSL_PKG}.hash"

# depends/packages/proton.mk (https://qpid.apache.org/proton/, Apache 2.0 license)
PROTON_PV="0.17.0"
PROTON_PKG="qpid-proton-${PROTON_PV}.tar.gz"
PROTON_HASH="6ffd26d3d0e495bfdb5d9fefc5349954e6105ea18cc4bb191161d27742c5a01a"
PROTON_URI="https://z.cash/depends-sources/${PROTON_PKG}"
PROTON_STAMP=".stamp_fetched-proton-${PROTON_PKG}.hash"

# depends/packages/librustzcash.mk (https://github.com/zcash/librustzcash, Apache 2.0 / MIT license)
RUSTZCASH_PV="91348647a86201a9482ad4ad68398152dc3d635e"
RUSTZCASH_PKG="librustzcash-${RUSTZCASH_PV}.tar.gz"
RUSTZCASH_HASH="a5760a90d4a1045c8944204f29fa2a3cf2f800afee400f88bf89bbfe2cce1279"
RUSTZCASH_URI="https://z.cash/depends-sources/${RUSTZCASH_PKG}"
RUSTZCASH_STAMP=".stamp_fetched-librustzcash-${RUSTZCASH_PKG}.hash"

# crate dependency for librustzcash
CRATES="libc-0.2.21"
cargo_crate_uris() {
	local crate
	for crate in "$@"; do
		local name version url
		name="${crate%-*}"
		version="${crate##*-}"
		url="https://crates.io/api/v1/crates/${name}/${version}/download -> ${crate}.crate"
		echo "${url}"
	done
}

MY_PV=${PV/_/-}
DESCRIPTION="Cryptocurrency that offers privacy of transactions"
HOMEPAGE="https://z.cash"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	${BDB_URI}
	${GMOCK_URI} -> ${GMOCK_PKG}
	${GTEST_URI} -> ${GTEST_PKG}
	bundled-ssl? ( ${OPENSSL_URI} )
	proton? ( ${PROTON_URI} )
	rust? (
		${RUSTZCASH_URI} -> ${RUSTZCASH_PKG}
		$(cargo_crate_uris ${CRATES})
	)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bundled-ssl examples hardened libressl libs mining proton reduce-exports rust zeromq"

DEPEND="dev-libs/boost:0=[threads(+)]
	>=dev-libs/gmp-6.1.0
	>=dev-libs/libevent-2.1.8
	dev-libs/libsodium:0=[-minimal]
	!bundled-ssl? (
		!libressl? ( dev-libs/openssl:0=[-bindist] )
		libressl? ( dev-libs/libressl:0= )
	)
	rust? ( >=dev-util/cargo-0.16.0 )
	zeromq? ( >=net-libs/zeromq-4.2.1 )"
RDEPEND="${DEPEND}"

REQUIRED_USE="bundled-ssl? ( !libressl )"
RESTRICT="mirror"

DOCS=( doc/{payment-api,security-warnings,tor}.md )

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_setup() {
	enewgroup zcash
	enewuser zcash -1 -1 /var/lib/zcashd zcash
}

src_unpack() {
	# Unpack only the main source
	unpack ${P}.tar.gz

	if use rust; then
		# This is a snippets from cargo.eclass
		# Author: Doug Goldstein <cardoe@gentoo.org>
		ECARGO_HOME="${WORKDIR}/cargo_home"
		ECARGO_VENDOR="${ECARGO_HOME}/gentoo"
		export CARGO_HOME="${ECARGO_HOME}"
		mkdir -p "${ECARGO_VENDOR}" || die
		for archive in ${A}; do
			case "${archive}" in
				*.crate)
					ebegin "Loading ${archive} into Cargo registry"
					tar -xf "${DISTDIR}"/${archive} -C "${ECARGO_VENDOR}/" || die
					# generate sha256sum of the crate itself as cargo needs this
					shasum=$(sha256sum "${DISTDIR}"/${archive} | cut -d ' ' -f 1)
					pkg=$(basename ${archive} .crate)
					cat <<- EOF > ${ECARGO_VENDOR}/${pkg}/.cargo-checksum.json
					{
						"package": "${shasum}",
						"files": {}
					}
					EOF
					eend $?
					;;
			esac
		done
		cat <<- EOF > "${ECARGO_HOME}/config"
		[source.gentoo]
		directory = "${ECARGO_VENDOR}"

		[source.crates-io]
		replace-with = "gentoo"
		local-registry = "/nonexistant"
		EOF
	fi
}

src_prepare() {
	local DEP_SRC STAMP_DIR LIBS X
	local native_packages packages
	DEP_SRC="${S}/depends/sources"
	STAMP_DIR="${DEP_SRC}/download-stamps"

	# Prepare download-stamps
	mkdir -p "${STAMP_DIR}" || die
	echo "${BDB_HASH} ${BDB_PKG}" > "${STAMP_DIR}/${BDB_STAMP}" || die
	echo "${GMOCK_HASH} ${GMOCK_PKG}" > "${STAMP_DIR}/${GMOCK_STAMP}" || die
	echo "${GTEST_HASH} ${GTEST_PKG}" > "${STAMP_DIR}/${GTEST_STAMP}" || die

	# Symlink dependencies
	ln -s "${DISTDIR}"/${BDB_PKG} "${DEP_SRC}" || die
	ln -s "${DISTDIR}"/${GMOCK_PKG} "${DEP_SRC}" || die
	ln -s "${DISTDIR}"/${GTEST_PKG} "${DEP_SRC}" || die

	if use bundled-ssl; then
		echo "${OPENSSL_HASH} ${OPENSSL_PKG}" > "${STAMP_DIR}/${OPENSSL_STAMP}" || die
		ln -s "${DISTDIR}"/${OPENSSL_PKG} "${DEP_SRC}" || die
	fi

	if use proton; then
		echo "${PROTON_HASH} ${PROTON_PKG}" > "${STAMP_DIR}/${PROTON_STAMP}" || die
		ln -s "${DISTDIR}"/${PROTON_PKG} "${DEP_SRC}" || die
	fi

	if use rust; then
		echo "${RUSTZCASH_HASH} ${RUSTZCASH_PKG}" > "${STAMP_DIR}/${RUSTZCASH_STAMP}" || die
		ln -s "${DISTDIR}"/${RUSTZCASH_PKG} "${DEP_SRC}" || die

		# There's no need to build the bundled rust
		sed -i 's:$(package)_dependencies=.*::g' \
			depends/packages/librustzcash.mk || die
	fi

	ebegin "Building bundled dependencies"
	pushd depends > /dev/null || die
	make install \
		native_packages="" \
		packages="bdb googletest googlemock \
			$(usex bundled-ssl openssl '') \
			$(usex proton proton '') \
			$(usex rust librustzcash '')" || die
	popd > /dev/null || die
	eend $?

	default
	./autogen.sh || die
}

src_configure() {
	local depends_prefix
	append-cppflags "-I${S}/depends/x86_64-unknown-linux-gnu/include"
	append-ldflags "-L${S}/depends/x86_64-unknown-linux-gnu/lib \
		-L${S}/depends/x86_64-unknown-linux-gnu/lib64"

	econf \
		depends_prefix="${S}/depends/x86_64-unknown-linux-gnu" \
		--prefix="${EPREFIX}"/usr \
		--disable-ccache \
		--disable-tests \
		$(use_enable hardened hardening) \
		$(use_enable mining) \
		$(use_enable proton) \
		$(use_enable reduce-exports) \
		$(use_enable rust) \
		$(use_enable zeromq zmq) \
		$(use_with libs) \
		|| die "econf failed"
}

src_install() {
	local X
	default

	newinitd "${FILESDIR}"/zcash.initd-r4 zcash
	newconfd "${FILESDIR}"/zcash.confd-r4 zcash
	systemd_newunit "${FILESDIR}"/zcash.service-r1 zcash.service
	systemd_newtmpfilesd "${FILESDIR}"/zcash.tmpfilesd-r2 zcash.conf

	insinto /etc/zcash
	doins "${FILESDIR}"/zcash.conf
	fowners zcash:zcash /etc/zcash/zcash.conf
	fperms 0600 /etc/zcash/zcash.conf
	newins contrib/debian/examples/zcash.conf zcash.conf.example

	for X in '-cli' '-tx' 'd'; do
		newbashcomp contrib/bitcoin${X}.bash-completion zcash${X}
	done

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/zcash.logrotate zcash

	if use examples; then
		docinto examples
		dodoc -r contrib/{bitrpc,qos,spendfrom}
		docompress -x /usr/share/doc/${PF}/examples
	fi
}

pkg_postinst() {
	ewarn
	ewarn "SECURITY WARNINGS:"
	ewarn "Zcash is experimental and a work-in-progress. Use at your own risk."
	ewarn
	ewarn "Please, see important security warnings in"
	ewarn "${EROOT%/}/usr/share/doc/${P}/security-warnings.md.bz2"
	ewarn
	if [ -z "${REPLACING_VERSIONS}" ]; then
		einfo
		elog "You should manually fetch the parameters for all users:"
		elog "$ zcash-fetch-params"
		elog
		elog "This script will fetch the Zcash zkSNARK parameters and verify"
		elog "their integrity with sha256sum."
		elog
		elog "The parameters are currently just under 911MB in size, so plan accordingly"
		elog "for your bandwidth constraints. If the files are already present and"
		elog "have the correct sha256sum, no networking is used."
		einfo
	fi
}
