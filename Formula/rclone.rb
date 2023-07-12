class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/v1.63.0.tar.gz"
  sha256 "755af528052f946e8d41a3e96e5dbf8f03ecfe398f9d0fdeb7ca1a59208a75db"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  depends_on "go" => :build

  # Fix builds on macOS < 12.
  patch do
    url "https://github.com/rclone/rclone/commit/c5a6821a8f09b1ac88e246a775d99271fa12cecd.patch?full_index=1"
    sha256 "ca7fdb4200fc4e2919c99a3d392779ccf65ffe8f10bfde4c965fef8e4984d585"
  end

  def install
    args = *std_go_args(ldflags: "-s -w -X github.com/rclone/rclone/fs.Version=v#{version}")
    args += ["-tags", "brew"] if OS.mac?
    system "go", "build", *args
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  def caveats
    <<~EOS
      Homebrew's installation does not include the `mount` subcommand on MacOS.
    EOS
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
