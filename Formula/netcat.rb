class Netcat < Formula
  desc "Utility for managing network connections"
  homepage "https://netcat.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/netcat/netcat/0.7.1/netcat-0.7.1.tar.bz2"
  sha256 "b55af0bbdf5acc02d1eb6ab18da2acd77a400bafd074489003f3df09676332bb"
  license "GPL-2.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    # Regenerate configure script for arm64/Apple Silicon support.
    system "autoreconf", "--verbose", "--install", "--force"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--infodir=#{info}"
    system "make", "install"
    man1.install_symlink "netcat.1" => "nc.1"
  end

  test do
    output = pipe_output("#{bin}/nc google.com 80", "GET / HTTP/1.0\r\n\r\n")
    assert_equal "HTTP/1.0 200 OK", output.lines.first.chomp
  end
end
