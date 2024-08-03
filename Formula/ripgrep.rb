class Ripgrep < Formula
  desc "Search tool like grep and The Silver Searcher"
  homepage "https://github.com/BurntSushi/ripgrep"
  url "https://github.com/BurntSushi/ripgrep/archive/refs/tags/14.1.0.tar.gz"
  sha256 "33c6169596a6bbfdc81415910008f26e0809422fda2d849562637996553b2ab6"
  license "Unlicense"
  head "https://github.com/BurntSushi/ripgrep.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end


  depends_on "asciidoctor" => :build
  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "pcre2"

  def install
    system "cargo", "install", "--features", "pcre2", *std_cargo_args

    generate_completions_from_executable(bin/"rg", "--generate", base_name: "rg", shell_parameter_format: "complete-")
    (man1/"rg.1").write Utils.safe_popen_read(bin/"rg", "--generate", "man")
  end

  test do
    (testpath/"Hello.txt").write("Hello World!")
    system bin/"rg", "Hello World!", testpath
  end
end
