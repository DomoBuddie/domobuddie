EAPI="6"

EFL_USE_GIT="yes"
EFL_GIT_REPO_CATEGORY="apps"

inherit meson

DESCRIPTION="EFL based terminal emulator"
HOMEPAGE="http://www.enlightenment.org/p.php?p=about/terminology"

EGIT_REPO_URI="https://git.enlightenment.org/apps/${PN}.git"

IUSE=""

RDEPEND="
	>=dev-libs/efl-9999"

DEPEND="${RDEPEND}"
