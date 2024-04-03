class Blueutil < Formula
  desc "Get/set bluetooth power and discoverable state"
  homepage "https://github.com/toy/blueutil"
  url "https://github.com/toy/blueutil/archive/refs/tags/v2.9.1.tar.gz"
  sha256 "50e50ebfa933f285d934d886a0209332df3088c3d25952c994f8bdb349f435ed"
  license "MIT"
  head "https://github.com/toy/blueutil.git", branch: "master"

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
    system bin/"blueutil", "--discoverable", "0"
    assert_match version.to_s, shell_output("#{bin}/blueutil --version")
  end
end
