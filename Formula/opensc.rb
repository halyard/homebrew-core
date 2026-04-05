class Opensc < Formula
  desc "Tools and libraries for smart cards"
  homepage "https://github.com/OpenSC/OpenSC/wiki"
  url "https://github.com/OpenSC/OpenSC/releases/download/0.27.1/opensc-0.27.1.tar.gz"
  sha256 "976f4a23eaf3397a1a2c3a7aac80bf971a8c3d829c9a79f06145bfaeeae5eca7"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/OpenSC/OpenSC.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "docbook-xsl" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  uses_from_macos "libxslt" => :build # for xsltproc
  uses_from_macos "pcsc-lite"

  on_linux do
    depends_on "glib"
    depends_on "readline"
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      --disable-silent-rules
      --enable-openssl
      --enable-pcsc
      --enable-sm
      --with-xsl-stylesheetsdir=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
    ]

    system "./bootstrap" if build.head?
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  def caveats
    on_macos do
      <<~EOS
        The OpenSSH PKCS11 smartcard integration will not work.
        If you need this functionality, unlink this formula, then install
        the OpenSC cask.
      EOS
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/opensc-tool -i")
  end
end
