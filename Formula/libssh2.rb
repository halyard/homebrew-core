class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "https://www.libssh2.org/"
  url "https://www.libssh2.org/download/libssh2-1.11.0.tar.gz"
  mirror "https://github.com/libssh2/libssh2/releases/download/libssh2-1.11.0/libssh2-1.11.0.tar.gz"
  mirror "http://download.openpkg.org/components/cache/libssh2/libssh2-1.11.0.tar.gz"
  sha256 "3736161e41e2693324deb38c26cfdc3efe6209d634ba4258db1cecff6a5ad461"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url "https://www.libssh2.org/download/"
    regex(/href=.*?libssh2[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  head do
    url "https://github.com/libssh2/libssh2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl@3"

  uses_from_macos "zlib"

  def install
    args = %W[
      --disable-silent-rules
      --disable-examples-build
      --with-openssl
      --with-libz
      --with-libssl-prefix=#{Formula["openssl@3"].opt_prefix}
    ]

    system "./buildconf" if build.head?
    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libssh2.h>

      int main(void)
      {
      libssh2_exit();
      return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lssh2", "-o", "test"
    system "./test"
  end
end
