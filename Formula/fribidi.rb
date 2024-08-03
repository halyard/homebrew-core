class Fribidi < Formula
  desc "Implementation of the Unicode BiDi algorithm"
  homepage "https://github.com/fribidi/fribidi"
  url "https://github.com/fribidi/fribidi/releases/download/v1.0.15/fribidi-1.0.15.tar.xz"
  sha256 "0bbc7ff633bfa208ae32d7e369cf5a7d20d5d2557a0b067c9aa98bcbf9967587"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make", "install"
  end

  test do
    (testpath/"test.input").write <<~EOS
      a _lsimple _RteST_o th_oat
    EOS

    assert_match "a simple TSet that", shell_output("#{bin}/fribidi --charset=CapRTL --test test.input")
  end
end
