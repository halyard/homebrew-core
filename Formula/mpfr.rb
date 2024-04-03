class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "https://www.mpfr.org/"
  url "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/mpfr/mpfr-4.2.1.tar.xz"
  sha256 "277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://www.mpfr.org/mpfr-current/"
    regex(/href=.*?mpfr[._-]v?(\d+(?:\.\d+)+)\.t/i)
    strategy :page_match do |page, regex|
      version = page.scan(regex).map { |match| Version.new(match[0]) }.max&.to_s
      next if version.blank?

      patch = page.scan(%r{href=["']?/?patch(\d+)["' >]}i)
                  .map { |match| Version.new(match[0]) }
                  .max
                  &.to_s
      next version if patch.blank?

      "#{version}-p#{patch.to_i}"
    end
  end

  head do
    url "https://gitlab.inria.fr/mpfr/mpfr.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "gmp"

  def install
    system "./autogen.sh" if build.head?

    system "./configure", *std_configure_args,
                          "--disable-silent-rules"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mpfr.h>
      #include <math.h>
      #include <stdlib.h>
      #include <string.h>

      int main() {
        mpfr_t x, y;
        mpfr_inits2 (256, x, y, NULL);
        mpfr_set_ui (x, 2, MPFR_RNDN);
        mpfr_rootn_ui (y, x, 2, MPFR_RNDN);
        mpfr_pow_si (x, y, 4, MPFR_RNDN);
        mpfr_add_si (y, x, -4, MPFR_RNDN);
        mpfr_abs (y, y, MPFR_RNDN);
        if (fabs(mpfr_get_d (y, MPFR_RNDN)) > 1.e-30) abort();
        if (strcmp("#{version}", mpfr_get_version())) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-L#{Formula["gmp"].opt_lib}",
                   "-lgmp", "-lmpfr", "-o", "test"
    system "./test"
  end
end
