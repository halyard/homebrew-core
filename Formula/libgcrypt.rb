class Libgcrypt < Formula
  desc "Cryptographic library based on the code from GnuPG"
  homepage "https://gnupg.org/related_software/libgcrypt/"
  url "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.10.2.tar.bz2"
  sha256 "3b9c02a004b68c256add99701de00b383accccf37177e0d6c58289664cce0c03"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/libgcrypt/"
    regex(/href=.*?libgcrypt[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "libgpg-error"

  on_macos do
    # Fix for build failure on macOS. Reported upstream at:
    # https://dev.gnupg.org/T6442
    patch :DATA
  end

  def install
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--enable-static",
                          "--disable-asm",
                          "--with-libgpg-error-prefix=#{Formula["libgpg-error"].opt_prefix}"

    # The jitter entropy collector must be built without optimisations
    ENV.O0 { system "make", "-C", "random", "rndjent.o", "rndjent.lo" }

    # Parallel builds work, but only when run as separate steps
    system "make"
    MachO.codesign!("#{buildpath}/tests/.libs/random") if OS.mac? && Hardware::CPU.arm?

    system "make", "check"
    system "make", "install"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"libgcrypt-config", prefix, opt_prefix
  end

  test do
    touch "testing"
    output = shell_output("#{bin}/hmac256 \"testing\" testing")
    assert_match "0e824ce7c056c82ba63cc40cffa60d3195b5bb5feccc999a47724cc19211aef6", output
  end
end

__END__
diff --git a/random/rndgetentropy.c b/random/rndgetentropy.c
index 513da0b..d8eedce 100644
--- a/random/rndgetentropy.c
+++ b/random/rndgetentropy.c
@@ -81,27 +81,8 @@ _gcry_rndgetentropy_gather_random (void (*add)(const void*, size_t,
       do
         {
           _gcry_pre_syscall ();
-          if (fips_mode ())
-            {
-              /* DRBG chaining defined in SP 800-90A (rev 1) specify
-               * the upstream (kernel) DRBG needs to be reseeded for
-               * initialization of downstream (libgcrypt) DRBG. For this
-               * in RHEL, we repurposed the GRND_RANDOM flag of getrandom API.
-               * The libgcrypt DRBG is initialized with 48B of entropy, but
-               * the kernel can provide only 32B at a time after reseeding
-               * so we need to limit our requests to 32B here.
-               * This is clarified in IG 7.19 / IG D.K. for FIPS 140-2 / 3
-               * and might not be applicable on other FIPS modules not running
-               * RHEL kernel.
-               */
-              nbytes = length < 32 ? length : 32;
-              ret = getrandom (buffer, nbytes, GRND_RANDOM);
-            }
-          else
-            {
-              nbytes = length < sizeof (buffer) ? length : sizeof (buffer);
-              ret = getentropy (buffer, nbytes);
-            }
+          nbytes = length < sizeof (buffer) ? length : sizeof (buffer);
+          ret = getentropy (buffer, nbytes);
           _gcry_post_syscall ();
         }
       while (ret == -1 && errno == EINTR);
