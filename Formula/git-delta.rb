class GitDelta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  url "https://github.com/dandavison/delta/archive/refs/tags/0.17.0.tar.gz"
  sha256 "1abd21587bcc1f2ef0cd342784ce990da9978bc345578e45506419e0952de714"
  license "MIT"
  head "https://github.com/dandavison/delta.git", branch: "main"

  depends_on "rust" => :build
  uses_from_macos "zlib"

  def install
    system "cargo", "install", *std_cargo_args
    bash_completion.install "etc/completion/completion.bash" => "delta"
    fish_completion.install "etc/completion/completion.fish" => "delta.fish"
    zsh_completion.install "etc/completion/completion.zsh" => "_delta"
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
