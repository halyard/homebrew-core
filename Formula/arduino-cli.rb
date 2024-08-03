class ArduinoCli < Formula
  desc "Arduino command-line interface"
  homepage "https://github.com/arduino/arduino-cli"
  url "https://github.com/arduino/arduino-cli/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "5987889e3a2675a8aca6488026826147dc82a5573ab61ed187cab40f4b6f433b"
  license "GPL-3.0-only"
  head "https://github.com/arduino/arduino-cli.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/arduino/arduino-cli/version.versionString=#{version}
      -X github.com/arduino/arduino-cli/version.commit=#{tap.user}
      -X github.com/arduino/arduino-cli/version.date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"arduino-cli", "completion")
  end

  test do
    system bin/"arduino-cli", "sketch", "new", "test_sketch"
    assert_predicate testpath/"test_sketch/test_sketch.ino", :exist?

    assert_match version.to_s, shell_output("#{bin}/arduino-cli version")
  end
end
