class TidyHtml5 < Formula
  desc "Granddaddy of HTML tools, with support for modern standards"
  homepage "https://www.html-tidy.org/"
  url "https://github.com/htacg/tidy-html5/archive/refs/tags/5.8.0.tar.gz"
  sha256 "59c86d5b2e452f63c5cdb29c866a12a4c55b1741d7025cf2f3ce0cde99b0660e"
  license "Zlib"
  head "https://github.com/htacg/tidy-html5.git", branch: "next"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d*?[02468](?:\.\d+)*)$/i)
  end

  depends_on "cmake" => :build

  def install
    cd "build/cmake"
    system "cmake", "../..", *std_cmake_args
    system "make"
    system "make", "install"
  end

  test do
    output = pipe_output(bin/"tidy -q", "<!doctype html><title></title>")
    assert_match(/^<!DOCTYPE html>/, output)
    assert_match "HTML Tidy for HTML5", output
  end
end
