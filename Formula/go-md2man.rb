class GoMd2man < Formula
  desc "Converts markdown into roff (man pages)"
  homepage "https://github.com/cpuguy83/go-md2man"
  url "https://github.com/cpuguy83/go-md2man.git",
      tag:      "v2.0.4",
      revision: "d6816bfbea7506064a28119f805fb79f9bc5aeec"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
    system bin/"go-md2man", "-in=go-md2man.1.md", "-out=go-md2man.1"
    man1.install "go-md2man.1"
  end

  test do
    assert_includes pipe_output(bin/"go-md2man", "# manpage\nand a half\n"),
                    ".TH manpage\n.PP\nand a half\n"
  end
end
