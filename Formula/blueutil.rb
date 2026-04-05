class Blueutil < Formula
  desc "Get/set bluetooth power and discoverable state"
  homepage "https://github.com/toy/blueutil"
  url "https://github.com/toy/blueutil/archive/refs/tags/v2.13.0.tar.gz"
  sha256 "d6beba603ab6638f72d9966aed33343f35cac441fc48a81c04fd532c844f170d"
  license "MIT"
  head "https://github.com/toy/blueutil.git", branch: "main"

  depends_on xcode: :build
  depends_on :macos

  def install
    # Set to build with SDK=macosx10.6, but it doesn't actually need 10.6
    xcodebuild "-arch", Hardware::CPU.arch,
               "SDKROOT=",
               "SYMROOT=build",
               "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    bin.install "build/Release/blueutil"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/blueutil --version")
    # We cannot test any useful command since Sonoma as OS privacy restrictions
    # will wait until Bluetooth permission is either accepted or rejected.
    system bin/"blueutil", "--discoverable", "0" if MacOS.version < :sonoma
  end
end
