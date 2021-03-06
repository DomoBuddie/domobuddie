# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils meson
[ "${PV}" = 9999 ] && inherit git-r3 autotools

DESCRIPTION="Enlightenment DR19 window manager"
HOMEPAGE="https://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"
[ "${PV}" = 9999 ] || SRC_URI="http://download.enlightenment.org/rel/apps/${PN}/${P/_/-}.tar.xz"

LICENSE="BSD-2"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0"

E_MODULES_DEFAULT=(
	conf-applications conf-bindings conf-dialogs conf-display conf-interaction
	conf-intl conf-menus conf-paths conf-performance conf-randr conf-shelves
	conf-theme conf-window-manipulation conf-window-remembers

	appmenu backlight battery bluez4 clock conf connman cpufreq everything
	fileman fileman-opinfo gadman geolocation ibar ibox lokker mixer msgbus music-control
	notification pager pager-plain quickaccess shot start syscon systray tasks time
	teamwork temperature tiling winlist wizard xkbswitch
	wl-weekeyboard wl-wl wl-x11
)
E_MODULES=(
	packagekit #wl-desktop-shell wl-drm wl-fb wl-x11
)
IUSE_E_MODULES=(
	"${E_MODULES_DEFAULT[@]/#/+enlightenment_modules_}"
	"${E_MODULES[@]/#/enlightenment_modules_}"
)
IUSE="doc +eeze egl nls pam pm-utils static-libs systemd +udev udisks ukit wayland ${IUSE_E_MODULES[@]}"

# maybe even dev-libs/wlc for wayland USE flag
RDEPEND="
	>=dev-libs/efl-9999[X,egl?,wayland?]
	virtual/udev
	x11-libs/libxcb
	x11-libs/xcb-util-keysyms
	enlightenment_modules_mixer? ( >=media-libs/alsa-lib-1.0.8 )
	nls? ( sys-devel/gettext )
	pam? ( sys-libs/pam )
	pm-utils? ( sys-power/pm-utils )
	systemd? ( sys-apps/systemd )
	wayland? (
		>=dev-libs/wayland-1.3.0
		>=dev-libs/weston-1.11.0
		>=x11-libs/pixman-0.31.1
		>=x11-libs/libxkbcommon-0.3.1
	)"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P/_/-}"


src_prepare() {
	default
	efl_src_prepare
}

src_configure() {
	local emesonargs=(
	    -Dpam=$(usex pam true false)
	    -Dsystemd=$(usex systemd true false)
	    -Dmount-eeze=$(usex eeze true false)
	    -Ddevice-udev=$(usex udev true false)
	    -Dmount-udisks=$(usex udisks true false)
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
}
