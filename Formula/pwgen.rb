class Pwgen < Formula
  desc "Password generator"
  homepage "https://pwgen.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/pwgen/pwgen/2.08/pwgen-2.08.tar.gz"
  sha256 "dab03dd30ad5a58e578c5581241a6e87e184a18eb2c3b2e0fffa8a9cf105c97b"
  license "GPL-2.0"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    system "#{bin}/pwgen", "--secure", "20", "10"
  end
end
