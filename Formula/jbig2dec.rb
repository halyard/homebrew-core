class Jbig2dec < Formula
  desc "JBIG2 decoder and library (for monochrome documents)"
  homepage "https://github.com/ArtifexSoftware/jbig2dec"
  url "https://github.com/ArtifexSoftware/jbig2dec/archive/refs/tags/0.19.tar.gz"
  sha256 "e81b787ad0b147a437a52d9ce7de1a8f429655e8aa030383b6b2dd8919373717"
  license "AGPL-3.0-or-later"

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
