class Libtermkey < Formula
  desc "Library for processing keyboard entry from the terminal"
  homepage "https://www.leonerd.org.uk/code/libtermkey/"
  url "https://www.leonerd.org.uk/code/libtermkey/libtermkey-0.22.tar.gz"
  sha256 "6945bd3c4aaa83da83d80a045c5563da4edd7d0374c62c0d35aec09eb3014600"
  license "MIT"

  livecheck do
    url :homepage
    regex(/href=.*?libtermkey[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end


  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "unibilium"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "glib" => :build
  end

  def install
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end
  test do
    (testpath/"test.c").write <<~EOS
      #include <termkey.h>
      #include <stdio.h>

      int main() {
        TermKey *tk = termkey_new(0, 0);
        if (tk == NULL) {
          fprintf(stderr, "Failed to initialize libtermkey\\n");
          return 1;
        }
        termkey_destroy(tk);
        printf("libtermkey initialized and destroyed successfully\\n");
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-ltermkey", "-I#{include}"
    assert_match "libtermkey initialized and destroyed successfully", shell_output("./test")
  end
end
