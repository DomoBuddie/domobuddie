EAPI="5"
DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="http://www.enlightenment.org/"
LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB"
inherit eutils git-r3 autotools

DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="http://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"
SLOT=”0”

src_prepare() {
eautoreconf
}
