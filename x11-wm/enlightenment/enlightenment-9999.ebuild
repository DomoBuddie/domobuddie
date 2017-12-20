EAPI="5"

inherit eutils git-r3 autotools

DESCRIPTION="Enlightenment window manager"
HOMEPAGE="http://www.enlightenment.org/"

EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"

LICENSE="BSD-2"
KEYWORDS="~amd64 ~x86"

SLOT="0"

DEPEND="dev-libs/efl
	virtual/udev
	x11-libs/libxcb
	x11-libs/xcb-util-keysyms
	media-libs/alsa-lib
	sys-devel/gettext
	sys-libs/pam
	sys-power/pm-utils
	sys-apps/systemd"

src_prepare() {
eautoreconf
}
