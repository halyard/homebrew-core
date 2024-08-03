class Rav1e < Formula
  desc "Fastest and safest AV1 video encoder"
  homepage "https://github.com/xiph/rav1e"
  license "BSD-2-Clause"
  head "https://github.com/xiph/rav1e.git", branch: "master"

  stable do
    url "https://github.com/xiph/rav1e/archive/refs/tags/v0.7.1.tar.gz"
    sha256 "da7ae0df2b608e539de5d443c096e109442cdfa6c5e9b4014361211cf61d030c"

    # keep the version in sync
    resource "Cargo.lock" do
      url "https://github.com/xiph/rav1e/releases/download/v0.7.1/Cargo.lock"
      sha256 "4482976bfb7647d707f9a01fa1a3848366988f439924b5c8ac7ab085fba24240"
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

  def install
    odie "Cargo.lock resource needs to be updated" if build.stable? && version != resource("Cargo.lock").version

    buildpath.install resource("Cargo.lock") if build.stable?
    system "cargo", "install", *std_cargo_args
    system "cargo", "cinstall", "--prefix", prefix
  end

  test do
    resource "homebrew-bus_qcif_7.5fps.y4m" do
      url "https://media.xiph.org/video/derf/y4m/bus_qcif_7.5fps.y4m"
      sha256 "1f5bfcce0c881567ea31c1eb9ecb1da9f9583fdb7d6bb1c80a8c9acfc6b66f6b"
    end

    testpath.install resource("homebrew-bus_qcif_7.5fps.y4m")
    system bin/"rav1e", "--tile-rows=2", "bus_qcif_7.5fps.y4m", "--output=bus_qcif_15fps.ivf"
  end
end
