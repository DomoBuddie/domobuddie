EAPI="6"

E_PKG_IUSE="doc nls"
EFL_USE_GIT="yes"
EFL_GIT_REPO_CATEGORY="core"

inherit pax-utils eutils git-r3 autotools

DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="http://www.enlightenment.org/"

EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"

SLOT="0"

IUSE="apulse +bmp debug drm +eet egl fbcon +fontconfig fribidi gesture gif gles glib gnutls gstreamer gstreamer010 harfbuzz +ico ibus jpeg2k libressl +multisense neon nls oldlua opengl ssl physics pixman +png postscript +ppm +psd pulseaudio raw scim sdl sound systemd tga tiff tslib v4l valgrind wayland webp X xim xine xpm"

REQUIRED_USE="
	egl?		( gles )
	multisense? ( pulseaudio )
	pulseaudio?	( sound )
	opengl?		( !gles !egl || ( X sdl wayland ) )
	gles?		( !opengl || ( X wayland ) )
	sdl?		( opengl !gles )
	wayland?	( || ( opengl gles ) )
	xim?		( X )
"

DEPEND="app-doc/doxygen
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
	media-libs/libsdl2
	media-libs/libsndfile
	media-libs/tiff
	x11-libs/tslib
	media-libs/libwebp
	media-libs/xine-lib
	x11-libs/libXpm
	media-libs/libraw
	app-text/poppler
	sys-power/pm-utils"

src_prepare() {
eapply_user
efl_src_prepare
}

src_configure() {
	if use ssl && use gnutls ; then
		einfo "You enabled both USE=ssl and USE=gnutls, but only one can be used;"
		einfo "gnutls has been selected for you."
	fi
	if use opengl && use gles ; then
		einfo "You enabled both USE=opengl and USE=gles, but only one can be used;"
		einfo "opengl has been selected for you."
	fi

	export MY_ECONF="
		${MY_ECONF}
		--with-profile=$(usex debug debug release)
		--with-crypto=$(usex gnutls gnutls $(usex ssl openssl none))
		--with-x11=$(usex X xlib none)
		$(use_with X x)
		--with-opengl=$(usex opengl full $(usex gles es none))
		--with-glib=$(usex glib)
		--enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-abb

		--enable-cserve
		--enable-image-loader-generic
		--enable-image-loader-jpeg

		--disable-tizen
		--enable-xinput2
		--disable-xinput22
		--enable-libmount
	"
		# external lz4 support currently broken because of unstable ABI/API
		#--enable-liblz4

	efl_src_configure
}

src_compile() {
	if host-is-pax && ! use oldlua ; then
		# We need to build the lua code first so we can pax-mark it. #547076
		local target='_e_built_sources_target_gogogo_'
		printf '%s: $(BUILT_SOURCES)\n' "${target}" >> src/Makefile || die
		emake -C src "${target}"
		emake -C src bin/elua/elua
		pax-mark m src/bin/elua/.libs/elua
	fi
	efl_src_compile
}


src_install() {
	MAKEOPTS+=" -j1"

	efl_src_install
}
