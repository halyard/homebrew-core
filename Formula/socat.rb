class Socat < Formula
  desc "SOcket CAT: netcat on steroids"
  homepage "http://www.dest-unreach.org/socat/"
  url "http://www.dest-unreach.org/socat/download/socat-1.8.0.0.tar.gz"
  sha256 "6010f4f311e5ebe0e63c77f78613d264253680006ac8979f52b0711a9a231e82"
  license "GPL-2.0-only"

  livecheck do
    url "http://www.dest-unreach.org/socat/download/"
    regex(/href=.*?socat[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "openssl@3"
  depends_on "readline"

  def install
    system "./configure", *std_configure_args, "--mandir=#{man}"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/socat - tcp:www.google.com:80", "GET / HTTP/1.0\r\n\r\n")
    assert_match "HTTP/1.0", output.lines.first
  end
end
