class Jbig2dec < Formula
  desc "JBIG2 decoder and library (for monochrome documents)"
  homepage "https://jbig2dec.com/"
  url "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs9531/jbig2dec-0.19.tar.gz"
  sha256 "279476695b38f04939aa59d041be56f6bade3422003a406a85e9792c27118a37"
  license "AGPL-3.0-or-later"

  # Not every GhostPDL release on GitHub provides a jbig2dec archive, so it's
  # necessary to check releases until we find one. Since the assets list HTML
  # is no longer part of release pages, it would take several requests to do
  # this. As it stands, this checks the homepage, even though it has typically
  # been slow to update the tarball link when a new version is released.
  livecheck do
    url :homepage
    regex(%r{href=.*?/jbig2dec[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  resource("test") do
    url "https://github.com/apache/tika/raw/master/tika-parsers/src/test/resources/test-documents/testJBIG2.jb2"
    sha256 "40764aed6c185f1f82123f9e09de8e4d61120e35d2b5c6ede082123749c22d91"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-silent-rules
      --without-libpng
    ]

    system "./autogen.sh", *args
    system "make", "install"
  end

  test do
    resource("test").stage testpath
    output = shell_output("#{bin}/jbig2dec -t pbm --hash testJBIG2.jb2")
    assert_match "aa35470724c946c7e953ddd49ff5aab9f8289aaf", output
    assert_predicate testpath/"testJBIG2.pbm", :exist?
  end
end
