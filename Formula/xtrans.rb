class Xtrans < Formula
  desc "X.Org: X Network Transport layer shared code"
  homepage "https://www.x.org/"
  url "https://www.x.org/archive/individual/lib/xtrans-1.5.0.tar.xz"
  sha256 "1ba4b703696bfddbf40bacf25bce4e3efb2a0088878f017a50e9884b0c8fb1bd"
  license "MIT"


  depends_on "pkg-config" => :build
  depends_on "util-macros" => :build
  depends_on "xorgproto" => :test

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-docs=no
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "X11/Xtrans/Xtrans.h"

      int main(int argc, char* argv[]) {
        Xtransaddr addr;
        return 0;
      }
    EOS
    system ENV.cc, "test.c"
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
