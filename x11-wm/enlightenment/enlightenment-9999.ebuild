EAPI="6"

E_PKG_IUSE="doc nls"
EFL_USE_GIT="yes"
EFL_GIT_REPO_CATEGORY="core"

inherit eutils git-r3 meson

DESCRIPTION="Enlightenment window manager"
HOMEPAGE="http://www.enlightenment.org/"

EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"

LICENSE="BSD-2"
KEYWORDS="~amd64 ~x86"

SLOT="0"

IUSE="eeze illume2 opengl pam pm-utils +sysactions systemd tracker
		+udev udisks wayland xinerama xscreensaver"

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
	#remove useless startup checks since we know we have the deps
	epatch "${FILESDIR}/quickstart.diff" || die

	efl_src_prepare
}

src_configure() {
	local emesonargs=(
	    -Dpam=$(usex pam true false)
	    -Dsystemd=$(usex systemd true false)
	    -Dmount-eeze=$(usex eeze true false)
	    -Ddevice-udev=$(usex udev true false)
	    -Dmount-udisks=$(usex udisks true false)
	    -Dinstall-sysactions=$(usex sysactions true false)
	    -Dwayland=$(usex wayland true false)
	    -Dxwayland=$(usex wayland true false)
	    -Dxwayland-bin=$(usex wayland true false)
	)
	meson_src_configure

	local module=

	for module in ${IUSE_ENLIGHTENMENT_MODULES}; do
		module="${module#+}"
		emesonargs+=" -D${module}=$(usex enlightenment_modules_${module} true false)"
	done
}

src_install() {
	meson_src_install
	insinto /etc/enlightenment

	newins "${FILESDIR}/gentoo-sysactions.conf" sysactions.conf

	if use debug; then
		einfo "Registering gdb into your /etc/enlightenment/sysactions.conf"

		echo "action: gdb /usr/bin/gdb" >>				\
							${D}/etc/enlightenment/sysactions.conf
	fi
}
