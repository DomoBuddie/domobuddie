EAPI="5"

inherit git-r3 efl meson

DESCRIPTION="Enlightenment window manager"
HOMEPAGE="http://www.enlightenment.org/"

EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"

LICENSE="BSD-2"
KEYWORDS="~amd64 ~x86"

SLOT="0"

E_MODULES_DEFAULT=(
	conf-applications conf-bindings conf-dialogs conf-display conf-interaction
	conf-intl conf-menus conf-paths conf-performance conf-randr conf-shelves
	conf-theme conf-window-manipulation conf-window-remembers

	appmenu backlight battery bluez4 clock connman contact cpufreq everything
	fileman fileman-opinfo gadman ibar ibox lokker mixer msgbus music-control
	notification pager pager16 quickaccess shot start syscon systray tasks
	teamwork temperature tiling winlist wizard xkbswitch
)

E_MODULES=(
	access packagkit wl-desktop-shell wl-drm wl-fb wl-x11
)
IUSE="doc +eeze egl +nls pam pm-utils static-libs systemd ukit wayland
	${E_MODULES_DEFAULT[@]/#/+enlightenment_modules_}
	${E_MODULES[@]/#/enlightenment_modules_}
"
REQUIED_USE="!udev? ( eeze )"


RDEPEND="|| ( >=dev-libs/efl-1.18.0 >=media-libs/elementary-1.17.0[X,wayland?] )
	virtual/udev
	x11-libs/libxcb
	x11-libs/xcb-util-keysyms
	enlightenment_modules_connman? ( net-misc/connman )
	enlightenment_modules_mixer? ( >=media-libs/alsa-lib-1.0.8 )
	nls? ( virtual/libintl )
	pam? ( sys-libs/pam )
	pm-utils? ( sys-power/pm-utils )
	systemd? ( sys-apps/systemd )
	wayland? (
		>=dev-libs/wayland-1.3.0
		>=x11-libs/pixman-0.31.1
		>=x11-libs/libxkbcommon-0.3.1
	)"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

DOCS=( AUTHORS ChangeLog README )

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
