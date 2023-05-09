class Rav1e < Formula
  desc "Fastest and safest AV1 video encoder"
  homepage "https://github.com/xiph/rav1e"
  license "BSD-2-Clause"
  head "https://github.com/xiph/rav1e.git", branch: "master"

  stable do
    url "https://github.com/xiph/rav1e/archive/v0.6.4.tar.gz"
    sha256 "33aaab7c57822ebda9070ace90a8161dbadf8971f73b53d4db885e8b5566a039"

    # keep the version in sync
    resource "Cargo.lock" do
      url "https://github.com/xiph/rav1e/releases/download/v0.6.4/Cargo.lock"
      sha256 "e5b8414eb3681e3f4f134625545ed9b1d6744e2278e9bef473aa74ce12632c7e"
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
