class LibpthreadStubs < Formula
  desc "X.Org: pthread-stubs.pc"
  homepage "https://www.x.org/"
  url "https://xcb.freedesktop.org/dist/libpthread-stubs-0.5.tar.xz"
  sha256 "59da566decceba7c2a7970a4a03b48d9905f1262ff94410a649224e33d2442bc"
  license "MIT"

  depends_on "pkgconf"

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    assert_equal version.to_s, shell_output("pkgconf --modversion pthread-stubs").chomp
  end
end
