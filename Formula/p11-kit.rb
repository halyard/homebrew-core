class P11Kit < Formula
  desc "Library to load and enumerate PKCS#11 modules"
  homepage "https://p11-glue.freedesktop.org"
  url "https://github.com/p11-glue/p11-kit/releases/download/0.25.3/p11-kit-0.25.3.tar.xz"
  sha256 "d8ddce1bb7e898986f9d250ccae7c09ce14d82f1009046d202a0eb1b428b2adc"
  license "BSD-3-Clause"

  head do
    url "https://github.com/p11-glue/p11-kit.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "ca-certificates"
  depends_on "libtasn1"

  uses_from_macos "libffi", since: :catalina

  def install
    # https://bugs.freedesktop.org/show_bug.cgi?id=91602#c1
    ENV["FAKED_MODE"] = "1"

    if build.head?
      ENV["NOCONFIGURE"] = "1"
      system "./autogen.sh"
    end

    args = %W[
      -Dsystem_config=#{etc}
      -Dmodule_config=#{etc}/pkcs11/modules
      -Dtrust_paths=#{etc}/ca-certificates/cert.pem"
      -Dsystemd=disabled
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    # This formula is used with crypto libraries, so let's run the test suite.
    system "meson", "test", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    system "#{bin}/p11-kit", "list-modules"
  end
end
