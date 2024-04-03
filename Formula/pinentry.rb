class Pinentry < Formula
  desc "Passphrase entry dialog utilizing the Assuan protocol"
  homepage "https://www.gnupg.org/related_software/pinentry/"
  url "https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.3.0.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/pinentry/pinentry-1.3.0.tar.bz2"
  sha256 "9b3cd5226e7597f2fded399a3bc659923351536559e9db0826981bca316494de"
  license "GPL-2.0-only"

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/pinentry/"
    regex(/href=.*?pinentry[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "libassuan"
  depends_on "libgpg-error"

  on_linux do
    depends_on "libsecret"
  end

  def install
    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1403

    args = %w[
      --disable-silent-rules
      --disable-pinentry-fltk
      --disable-pinentry-gnome3
      --disable-pinentry-gtk2
      --disable-pinentry-qt
      --disable-pinentry-qt5
      --disable-pinentry-tqt
      --enable-pinentry-tty
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    system "#{bin}/pinentry", "--version"
    system "#{bin}/pinentry-tty", "--version"
  end
end
