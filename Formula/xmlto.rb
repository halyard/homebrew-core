class Xmlto < Formula
  desc "Convert XML to another format (based on XSL or other tools)"
  homepage "https://pagure.io/xmlto/"
  url "https://pagure.io/xmlto/archive/0.0.29/xmlto-0.0.29.tar.gz"
  sha256 "40504db68718385a4eaa9154a28f59e51e59d006d1aa14f5bc9d6fded1d6017a"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://releases.pagure.org/xmlto/?C=M&O=D"
    regex(/href=.*?xmlto[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end


  depends_on "docbook"
  depends_on "docbook-xsl"
  # Doesn't strictly depend on GNU getopt, but macOS system getopt(1)
  # does not support longopts in the optstring, so use GNU getopt.
  depends_on "gnu-getopt"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  uses_from_macos "libxslt"

  def install
    # GNU getopt is keg-only, so point configure to it
    ENV["GETOPT"] = Formula["gnu-getopt"].opt_bin/"getopt"
    # Prevent reference to Homebrew shim
    ENV["SED"] = "/usr/bin/sed"
    # Find our docbook catalog
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    ENV.deparallelize
    system "autoreconf", "-fiv"
    system "autoconf"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test").write <<~EOS
      <?xmlif if foo='bar'?>
      Passing test.
      <?xmlif fi?>
    EOS
    assert_equal "Passing test.", pipe_output("#{bin}/xmlif foo=bar", (testpath/"test").read).strip
  end
end
