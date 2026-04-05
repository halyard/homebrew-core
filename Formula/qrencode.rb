class Qrencode < Formula
  desc "QR Code generation"
  homepage "https://fukuchi.org/works/qrencode/index.html.en"
  url "https://github.com/fukuchi/libqrencode/archive/refs/tags/v4.1.1.tar.gz"
  sha256 "5385bc1b8c2f20f3b91d258bf8ccc8cf62023935df2d2676b5b67049f31a049c"
  license "LGPL-2.1-or-later"
  compatibility_version 1
  head "https://github.com/fukuchi/libqrencode.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "libpng"

  def install
    args = %w[-DCMAKE_POLICY_VERSION_MINIMUM=3.5]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"qrencode", "123456789", "-o", "test.png"
  end
end
