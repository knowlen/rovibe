pkgname=rovibe
pkgver=0.1.0
pkgrel=1
pkgdesc='OS-level isolated agent identities for AI coding agents'
arch=(any)
license=(MIT)
depends=(bash git)
install=rovibe.install

package() {
  install -Dm755 "$startdir/rovibe" "$pkgdir/usr/local/bin/rovibe"
  install -dm755 "$pkgdir/usr/local/lib/rovibe"
  for f in "$startdir"/lib/*; do
    install -Dm755 "$f" "$pkgdir/usr/local/lib/rovibe/$(basename "$f")"
  done
}
