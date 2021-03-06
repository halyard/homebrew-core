class Gpgme < Formula
  desc "Library access to GnuPG"
  homepage "https://www.gnupg.org/related_software/gpgme/"
  url "https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.13.0.tar.bz2"
  sha256 "d4b23e47a9e784a63e029338cce0464a82ce0ae4af852886afda410f9e39c630"

  depends_on "gnupg"
  depends_on "libassuan"
  depends_on "libgpg-error"
  depends_on "pth"


  def install
    # Fix incorrect shared library suffix in CMake file
    # Reported 25 May 2017 https://dev.gnupg.org/T3181
    inreplace "lang/cpp/src/GpgmeppConfig.cmake.in.in", "libgpgme.so;",
                                                        "libgpgme.dylib;"

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make"
    system "make", "install"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"gpgme-config", prefix, opt_prefix
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gpgme-tool --lib-version")
  end
end
