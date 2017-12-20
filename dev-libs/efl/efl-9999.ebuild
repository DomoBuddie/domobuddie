EAPI="5"
DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="http://www.enlightenment.org/"
LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB"
inherit eutils git-r3 autotools

DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="http://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"
SLOT="0"

DEPEND="
	app-doc/doxygen
	dev-libs/check
	dev-libs/libinput
	media-libs/mesa
	x11-libs/libdrm
	x11-libs/libxkbcommon
	dev-lang/luajit
	sys-apps/dbus
	sys-libs/zlib
	virtual/jpeg
	virtual/udev
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXinerama
	x11-libs/libXp
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	virtual/opengl
	net-dns/avahi
	dev-util/valgrind
	media-libs/fontconfig
	dev-libs/fribidi
	media-libs/giflib
	dev-libs/glib
	net-libs/gnutls
	dev-libs/openssl
	media-libs/gstreamer
	media-libs/gst-plugins-base
	media-libs/harfbuzz
	app-i18n/ibus
	media-libs/openjpeg
	sys-devel/gettext
	dev-lang/lua
	sci-physics/bullet
	x11-libs/pixman
	app-text/libspectre
	media-libs/libpng
	media-sound/pulseaudio
	app-i18n/scim
	media-libs/libsdl2
	media-libs/libsndfile
	media-libs/tiff
	x11-libs/tslib
	media-libs/libwebp
	media-libs/xine-lib
	x11-libs/libXpm
	media-libs/libraw
	app-text/poppler
	sys-power/pm-utils
”

src_prepare() {
eautoreconf
}
