class Lazygit < Formula
  desc "A simple terminal UI for git commands, written in Go"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/releases/download/v0.7.2/lazygit_0.7.2_Darwin_x86_64.tar.gz"
  version "0.7.2"
  sha256 "a51fb5bebcde0c01b21ee8b2d75e13846601f9b996eb23ef87f5ea89775f0737"

  def install
    bin.install "lazygit"
  end
end
