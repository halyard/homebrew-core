class Cairo < Formula
  desc "Vector graphics library with cross-device output support"
  homepage "https://cairographics.org/"
  url "https://cairographics.org/releases/cairo-1.18.0.tar.xz"
  sha256 "243a0736b978a33dee29f9cca7521733b78a65b5418206fef7bd1c3d4cf10b64"
  license any_of: ["LGPL-2.1-only", "MPL-1.1"]
  head "https://gitlab.freedesktop.org/cairo/cairo.git", branch: "master"

  livecheck do
    url "https://cairographics.org/releases/?C=M&O=D"
    regex(%r{href=(?:["']?|.*?/)cairo[._-]v?(\d+\.\d*[02468](?:\.\d+)*)\.t}i)
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "glib"
  depends_on "libpng"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "libxext"
  depends_on "libxrender"
  depends_on "lzo"
  depends_on "pixman"

  uses_from_macos "zlib"

  def install
    args = %w[
      -Dfontconfig=enabled
      -Dfreetype=enabled
      -Dpng=enabled
      -Dglib=enabled
      -Dxcb=enabled
      -Dxlib=enabled
      -Dzlib=enabled
      -Dglib=enabled
    ]
    args << "-Dquartz=enabled" if OS.mac?

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cairo.h>

      int main(int argc, char *argv[]) {

        cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 600, 400);
        cairo_t *context = cairo_create(surface);

        return 0;
      }
    EOS
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/cairo
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -L#{lib}
      -lcairo
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
