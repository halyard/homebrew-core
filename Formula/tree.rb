class Tree < Formula
  desc "Display directories as trees (with optional color/HTML output)"
  homepage "https://oldmanprogrammer.net/source.php?dir=projects/tree"
  url "https://github.com/Old-Man-Programmer/tree/archive/refs/tags/2.1.3.tar.gz"
  sha256 "3ffe2c8bb21194b088ad1e723f0cf340dd434453c5ff9af6a38e0d47e0c2723b"
  license "GPL-2.0-or-later"


  def install
    ENV.append "CFLAGS", "-fomit-frame-pointer"
    objs = "tree.o list.o hash.o color.o file.o filter.o info.o unix.o xml.o json.o html.o strverscmp.o"

    system "make", "PREFIX=#{prefix}",
                   "MANDIR=#{man}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "OBJS=#{objs}",
                   "install"
  end

  test do
    system bin/"tree", prefix
  end
end
