class Freetype < Formula
  desc "Software library to render fonts"
  homepage "https://www.freetype.org/"
  url "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.0/freetype-2.13.0.tar.xz"
  mirror "https://download.savannah.gnu.org/releases/freetype/freetype-2.13.0.tar.xz"
  sha256 "5ee23abd047636c24b2d43c6625dcafc66661d1aca64dec9e0d05df29592624c"
  license "FTL"
  revision 1

  livecheck do
    url :stable
    regex(/url=.*?freetype[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "libpng"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  # Earlier versions of Apple Clang don't recognise the `fallthrough` attribute.
  # The following patches make it possible to build with them.
  # Remove both on next release.
  patch do
    url "https://gitlab.freedesktop.org/freetype/freetype/-/commit/2257f9abf6e12daf7c3e1bfe28fa88de85e45785.diff"
    sha256 "64f41363467c455ccfeb3350bc3bea0c028fa5d108821e2e81cd8475675b7926"
  end

  patch do
    url "https://gitlab.freedesktop.org/freetype/freetype/-/commit/d874ffa96ccad7dd122cdc369a284d171e221809.diff"
    sha256 "aff06e28afc48cd96d7ea4321069046db8ba0f512bf965ef475c1cdbcdc2635f"
  end

  def install
    # This file will be installed to bindir, so we want to avoid embedding the
    # absolute path to the pkg-config shim.
    inreplace "builds/unix/freetype-config.in", "%PKG_CONFIG%", "pkg-config"

    system "./configure", "--prefix=#{prefix}",
                          "--enable-freetype-config",
                          "--without-harfbuzz"
    system "make"
    system "make", "install"

    inreplace [bin/"freetype-config", lib/"pkgconfig/freetype2.pc"],
      prefix, opt_prefix
  end

  test do
    system bin/"freetype-config", "--cflags", "--libs", "--ftversion",
                                  "--exec-prefix", "--prefix"
  end
end
