class Libpng < Formula
  desc "Library for manipulating PNG images"
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.xz"
  mirror "https://sourceforge.mirrorservice.org/l/li/libpng/libpng16/1.6.43/libpng-1.6.43.tar.xz"
  sha256 "6a5ca0652392a2d7c9db2ae5b40210843c0bbc081cbd410825ab00cc59f14a6c"
  license "libpng-2.0"

  livecheck do
    url :stable
    regex(%r{url=.*?/libpng[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  head do
    url "https://github.com/glennrp/libpng.git", branch: "libpng16"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  uses_from_macos "zlib"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "test"
    system "make", "install"

    # Avoid rebuilds of dependants that hardcode this path.
    inreplace lib/"pkgconfig/libpng.pc", prefix, opt_prefix
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <png.h>

      int main()
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end
