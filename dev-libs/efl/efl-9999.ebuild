EAPI="6"

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
	[ ${PV} = 9999 ] && eautoreconf
	eapply_user
}

src_configure() {
	# if efreetd isn't already running it gets spawned as root with
	# default XDG_RUNTIME_DIR for example: /run/user/0
	export XDG_RUNTIME_DIR="${T}"

	local config=()

	# gnutls / openssl
	if use gnutls; then
		config+=( --with-crypto=gnutls )
		use ssl && \
			einfo "You enabled both USE=ssl and USE=gnutls, using gnutls"
	elif use ssl; then
		config+=( --with-crypto=openssl )
	else
		config+=( --with-crypto=none )
	fi

	# X
	config+=(
		$(use_with X x)
		$(use_with X x11 xlib)
	)
	if use opengl; then
		config+=( --with-opengl=full )
		use gles &&  \
			einfo "You enabled both USE=opengl and USE=gles, using opengl"
	elif use gles; then
		config+=( --with-opengl=es )
		if use sdl; then
			config+=( --with-opengl=none )
			ewarn "You enabled both USE=sdl and USE=gles which isn't currently supported."
			ewarn "Disabling gl for all backends."
		fi
	else
		config+=( --with-opengl=none )
	fi

	# wayland
	config+=(
		$(use_enable egl)
		$(use_enable wayland)
	)

	if use drm && use systemd; then
		config+=(
			--enable-drm
			--enable-gl-drm
			--enable-elput
		)
	else
		einfo "You cannot build DRM support without systemd support, disabling drm engine"
		config+=(
			--disable-drm
		)
	fi
	# bug 501074
	if use pixman; then
		config+=(
			--enable-pixman
			--enable-pixman-font
			--enable-pixman-rect
			--enable-pixman-line
			--enable-pixman-poly
			--enable-pixman-image
			--enable-pixman-image-scale-sample
		)
	else
		config+=(
			--disable-pixman
			--disable-pixman-font
			--disable-pixman-rect
			--disable-pixman-line
			--disable-pixman-poly
			--disable-pixman-image
			--disable-pixman-image-scale-sample
		)
	fi
	config+=(
		$(use_enable avahi)
		$(use_enable cxx-bindings cxx-bindings)
		$(use_enable doc)
		$(use_enable fbcon fb)
		$(use_enable fontconfig)
		$(use_enable fribidi)
		$(use_enable gstreamer gstreamer1)
		$(use_enable harfbuzz)
		$(use_enable ibus)
		$(use_enable nls)
		$(use_enable physics)
		$(use_enable pulseaudio)
		$(use_enable pulseaudio audio)
		$(use_enable scim)
		$(use_enable sdl)
		$(use_enable static-libs static)
		$(use_enable systemd)
		$(use_enable tslib)
		$(use_enable v4l2)
		$(use_enable xim)
		$(use_enable xine)
		$(use_enable xpresent)

		# image loders
		--enable-image-loader-bmp
		--enable-image-loader-eet
		--enable-image-loader-generic
		--enable-image-loader-ico
		--enable-image-loader-jpeg # required by ethumb
		--enable-image-loader-psd
		--enable-image-loader-pmaps
		--enable-image-loader-tga
		--enable-image-loader-wbmp
		$(use_enable gif image-loader-gif)
		$(use_enable jp2k image-loader-jp2k)
		$(use_enable png image-loader-png)
		$(use_enable tiff image-loader-tiff)
		$(use_enable webp image-loader-webp)
		$(use_enable xpm image-loader-xpm)

		--enable-cserve
		--enable-libmount
		--enable-threads
		--enable-xinput22

		--disable-gesture
		--disable-gstreamer # using gstreamer1
		--disable-lua-old
		--disable-multisense
		--disable-tizen
#		--disable-xinput2

		--with-profile=$(usex debug debug release)
		--with-glib=$(usex glib yes no)
		--with-tests=$(usex test regular none)

		--enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-abb
	)

	econf "${config[@]}"
}

src_install() {
	default
	prune_libtool_files
}
