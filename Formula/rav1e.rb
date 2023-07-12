class Rav1e < Formula
  desc "Fastest and safest AV1 video encoder"
  homepage "https://github.com/xiph/rav1e"
  license "BSD-2-Clause"
  head "https://github.com/xiph/rav1e.git", branch: "master"

  stable do
    url "https://github.com/xiph/rav1e/archive/v0.6.6.tar.gz"
    sha256 "723696e93acbe03666213fbc559044f3cae5b8b888b2ddae667402403cff51e5"

    # keep the version in sync
    resource "Cargo.lock" do
      url "https://github.com/xiph/rav1e/releases/download/v0.6.6/Cargo.lock"
      sha256 "2014f7d76e7d0d7eaa63158ef5a1a1cea15a095fd5fb79b20b1052015a7fcd0c"
    end
  end

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cargo-c" => :build
  depends_on "rust" => :build

  on_intel do
    depends_on "nasm" => :build
  end

  resource "homebrew-bus_qcif_7.5fps.y4m" do
    url "https://media.xiph.org/video/derf/y4m/bus_qcif_7.5fps.y4m"
    sha256 "1f5bfcce0c881567ea31c1eb9ecb1da9f9583fdb7d6bb1c80a8c9acfc6b66f6b"
  end

  def install
    buildpath.install resource("Cargo.lock") if build.stable?
    system "cargo", "install", *std_cargo_args
    system "cargo", "cinstall", "--prefix", prefix
  end

  test do
    assert_equal version, resource("Cargo.lock").version, "`Cargo.lock` resource needs updating!" unless head?
    resource("homebrew-bus_qcif_7.5fps.y4m").stage do
      system bin/"rav1e", "--tile-rows=2",
                          "bus_qcif_7.5fps.y4m",
                          "--output=bus_qcif_15fps.ivf"
    end
  end
end
