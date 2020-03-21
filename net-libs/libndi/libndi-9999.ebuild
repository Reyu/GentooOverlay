EAPI=7

inherit unpacker

DESCRIPTION="Provides the tools and resources for developers and manufacturers to easily add native NDI support to their video products"
HOMEPAGE="https://www.ndi.tv/"
SRC_URI="http://new.tk/NDISDKLINUX -> InstallNDISDK_v4_Linux.tar.gz"

IUSE="logos examples"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

RDEPEND="net-dns/avahi"

S=${WORKDIR}/NDI\ SDK\ for\ Linux

src_unpack() {
    unpack ${DISTDIR}/${A}
    ARCHIVE=`awk '/^__NDI_ARCHIVE_BEGIN__/ { print NR+1; exit 0; }' "${A/.tar.gz/.sh}"`
    tail -n+${ARCHIVE} ${A/.tar.gz/.sh} | tar xz
}

src_install() {
    elog ${PWD}
    dobin bin/x86_64-linux-gnu/ndi-directory-service
    dobin bin/x86_64-linux-gnu/ndi-record
    dolib.so lib/x86_64-linux-gnu/libndi.so.4.1.6
    dosym libndi.so.4.1.6 usr/lib64/libndi.so.4
    dosym libndi.so.4.1.6 usr/lib64/libndi.so
    pushd include ; doheader -r . ; popd
    dodoc -r documentation
    use logos && dodoc -r logos
    use examples && dodoc -r examples
}
