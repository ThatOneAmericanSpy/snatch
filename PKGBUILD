pkgname=snatch
pkgver=1.0.2
pkgrel=1
pkgdesc="A simple and lightweight aur helper"
arch=('any')
license=('MIT')
depends=('bash' 'jq' 'git' 'base-devel')

source=("snatch.sh")

sha256sums=('SKIP')

package() {
    install -Dm755 "${srcdir}/snatch.sh" "${pkgdir}/usr/bin/snatch"
}
