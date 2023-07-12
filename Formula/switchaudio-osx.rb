class SwitchaudioOsx < Formula
  desc "Change macOS audio source from the command-line"
  homepage "https://github.com/deweller/switchaudio-osx/"
  url "https://github.com/deweller/switchaudio-osx/archive/1.2.2.tar.gz"
  sha256 "3d12b57cbd6063a643a12f12287af99c87894c33449c6bcac0a71fd15776b3ed"
  license "MIT"
  head "https://github.com/deweller/switchaudio-osx.git", branch: "master"

  depends_on xcode: :build
  depends_on :macos

  def install
    xcodebuild "-project", "AudioSwitcher.xcodeproj",
               "-target", "SwitchAudioSource",
               "SYMROOT=build",
               "-verbose",
               "-arch", Hardware::CPU.arch,
               # Default target is 10.5, which fails on Mojave
               "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"
    prefix.install Dir["build/Release/*"]
    bin.write_exec_script "#{prefix}/SwitchAudioSource"
    chmod 0755, "#{bin}/SwitchAudioSource"
  end

  test do
    system "#{bin}/SwitchAudioSource", "-c"
  end
end
