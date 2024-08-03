class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/related_software/libgpg-error/"
  url "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.50.tar.bz2"
  sha256 "69405349e0a633e444a28c5b35ce8f14484684518a508dc48a089992fe93e20a"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/libgpg-error/"
    regex(/href=.*?libgpg-error[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end


  on_macos do
    depends_on "gettext"
  end

  # Declare environ - upstream bug https://dev.gnupg.org/T7169
  patch :DATA

  def install
    # NOTE: gpg-error-config is deprecated upstream, so we should remove this at some point.
    # https://dev.gnupg.org/T5683
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--enable-install-gpg-error-config",
                          "--enable-static"
    system "make", "install"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace [bin/"gpg-error-config", lib/"pkgconfig/gpg-error.pc"], prefix, opt_prefix
  end

  test do
    system bin/"gpgrt-config", "--libs"
  end
end

__END__
--- a/src/spawn-posix.c
+++ b/src/spawn-posix.c
@@ -57,7 +57,10 @@
 
 #include "gpgrt-int.h"
 
+/* (Only glibc's unistd.h declares this iff _GNU_SOURCE is used.)  */
+extern char **environ;
+ 
 
 /* Definition for the gpgrt_spawn_actions_t.  Note that there is a
  * different one for Windows.  */
 struct gpgrt_spawn_actions {

