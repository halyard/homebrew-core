class Xmlto < Formula
  desc "Convert XML to another format (based on XSL or other tools)"
  homepage "https://pagure.io/xmlto/"
  url "https://releases.pagure.org/xmlto/xmlto-0.0.28.tar.bz2"
  sha256 "1130df3a7957eb9f6f0d29e4aa1c75732a7dfb6d639be013859b5c7ec5421276"
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

  uses_from_macos "libxslt"

  def install
    # GNU getopt is keg-only, so point configure to it
    ENV["GETOPT"] = Formula["gnu-getopt"].opt_bin/"getopt"
    # Prevent reference to Homebrew shim
    ENV["SED"] = "/usr/bin/sed"
    # Find our docbook catalog
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    ENV.deparallelize
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
