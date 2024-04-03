class LibpthreadStubs < Formula
  desc "X.Org: pthread-stubs.pc"
  homepage "https://www.x.org/"
  url "https://xcb.freedesktop.org/dist/libpthread-stubs-0.5.tar.xz"
  sha256 "59da566decceba7c2a7970a4a03b48d9905f1262ff94410a649224e33d2442bc"
  license "MIT"

  depends_on "pkg-config"

  def install
    system "./configure", *std_configure_args.reject { |s| s["--disable-debug"] }
    system "make", "install"
  end

  test do
    system "pkg-config", "--exists", "pthread-stubs"
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
