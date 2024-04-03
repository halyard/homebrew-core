class Opensc < Formula
  desc "Tools and libraries for smart cards"
  homepage "https://github.com/OpenSC/OpenSC/wiki"
  url "https://github.com/OpenSC/OpenSC/releases/download/0.25.0/opensc-0.25.0.tar.gz"
  sha256 "e6d7b66e2a508a377ac9d67aa463025d3c54277227be10bd08872e3407d6622f"
  license "LGPL-2.1-or-later"
  head "https://github.com/OpenSC/OpenSC.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "docbook-xsl" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl@3"

  uses_from_macos "pcsc-lite"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-openssl
      --enable-pcsc
      --enable-sm
      --with-xsl-stylesheetsdir=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
    ]

    system "./bootstrap"
    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<~EOS
      The OpenSSH PKCS11 smartcard integration will not work from High Sierra
      onwards. If you need this functionality, unlink this formula, then install
      the OpenSC cask.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/opensc-tool -i")
  end
end
