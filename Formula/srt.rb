class Srt < Formula
  desc "Secure Reliable Transport"
  homepage "https://www.srtalliance.org/"
  license "MPL-2.0"
  compatibility_version 1
  head "https://github.com/Haivision/srt.git", branch: "master"

  stable do
    url "https://github.com/Haivision/srt/archive/refs/tags/v1.5.4.tar.gz"
    sha256 "d0a8b600fe1b4eaaf6277530e3cfc8f15b8ce4035f16af4a5eb5d4b123640cdd"

    # Fix to cmake 4 compatibility
    # PR ref: https://github.com/Haivision/srt/pull/3167
    patch do
      url "https://github.com/Haivision/srt/commit/7962936829e016295e5c570539eb2520b326da4c.patch?full_index=1"
      sha256 "e4489630886bf8b26f63a23c8b1aec549f7280f07713ded07fce281e542725f7"
    end
  end

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  def install
    openssl = Formula["openssl@3"]

    args = %W[
      -DWITH_OPENSSL_INCLUDEDIR=#{openssl.opt_include}
      -DWITH_OPENSSL_LIBDIR=#{openssl.opt_lib}
      -DCMAKE_INSTALL_BINDIR=bin
      -DCMAKE_INSTALL_LIBDIR=lib
      -DCMAKE_INSTALL_INCLUDEDIR=include
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    cmd = "#{bin}/srt-live-transmit file:///dev/null file://con/ 2>&1"
    assert_match "Unsupported source type", shell_output(cmd, 1)
  end
end
