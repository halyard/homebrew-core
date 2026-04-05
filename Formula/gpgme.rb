class Gpgme < Formula
  desc "Library access to GnuPG"
  homepage "https://www.gnupg.org/related_software/gpgme/"
  url "https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-2.0.1.tar.bz2"
  sha256 "821ab0695c842eab51752a81980c92b0410c7eadd04103f791d5d2a526784966"
  license "LGPL-2.1-or-later"
  compatibility_version 1

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/gpgme/"
    regex(/href=.*?gpgme[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "gnupg"
  depends_on "libassuan"
  depends_on "libgpg-error"

  def install
    system "./configure", "--disable-silent-rules",
                          "--enable-static",
                          *std_configure_args
    system "make"
    system "make", "install"

    inreplace bin/"gpgme-config" do |s|
      # avoid triggering mandatory rebuilds of software that hard-codes this path
      s.gsub! prefix, opt_prefix
      # replace libassuan Cellar paths to avoid breakage on libassuan version/revision bumps
      s.gsub! Formula["libassuan"].prefix.realpath, Formula["libassuan"].opt_prefix
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gpgme-tool --lib-version")

    (testpath/"test.c").write <<~C
      #include <gpgme.h>
      #include <locale.h>
      #include <stdio.h>

      void init_gpgme(void) {
        setlocale(LC_ALL, "");
        gpgme_check_version(NULL);
        gpgme_set_locale(NULL, LC_CTYPE, setlocale(LC_CTYPE, NULL));
      }

      int main() {
        init_gpgme();

        gpgme_ctx_t ctx;
        gpgme_error_t err = gpgme_new(&ctx);
        if (err) {
            fprintf(stderr, "gpgme_new error: %s\\n", gpgme_strerror(err));
            return 1;
        }

        printf("GPGME context created!\\n");
        gpgme_release(ctx);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lgpgme", "-o", "test"
    system "./test"
  end
end
