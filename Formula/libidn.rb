class Libidn < Formula
  desc "International domain name library"
  homepage "https://www.gnu.org/software/libidn/"
  url "https://ftp.gnu.org/gnu/libidn/libidn-1.42.tar.gz"
  mirror "https://ftpmirror.gnu.org/libidn/libidn-1.42.tar.gz"
  sha256 "d6c199dcd806e4fe279360cb4b08349a0d39560ed548ffd1ccadda8cdecb4723"
  license any_of: ["GPL-2.0-or-later", "LGPL-3.0-or-later"]


  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-csharp",
                          "--with-lispdir=#{elisp}"
    system "make", "install"
  end

  test do
    ENV["CHARSET"] = "UTF-8"
    system bin/"idn", "räksmörgås.se", "blåbærgrød.no"
  end
end
