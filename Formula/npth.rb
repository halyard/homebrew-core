class Npth < Formula
  desc "New GNU portable threads library"
  homepage "https://gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/npth/npth-1.7.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/npth/npth-1.7.tar.bz2"
  sha256 "8589f56937b75ce33b28d312fccbf302b3b71ec3f3945fde6aaa74027914ad05"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/npth/"
    regex(/href=.*?npth[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <npth.h>

      void* thread_function(void *arg) {
          printf("Hello from nPth thread!\\n");
          return NULL;
      }

      int main() {
          npth_t thread_id;
          int status;

          status = npth_init();
          if (status != 0) {
              fprintf(stderr, "Failed to initialize nPth.\\n");
              return 1;
          }

          status = npth_create(&thread_id, NULL, thread_function, NULL);
          npth_join(thread_id, NULL);
          return 0;
      }

    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lnpth", "-o", "test"
    assert_match "Hello from nPth thread!", shell_output("./test")
  end
end
