class Libyubikey < Formula
  desc "C library for manipulating Yubico one-time passwords"
  homepage "https://yubico.github.io/yubico-c/"
  url "https://developers.yubico.com/yubico-c/Releases/libyubikey-1.13.tar.gz"
  sha256 "04edd0eb09cb665a05d808c58e1985f25bb7c5254d2849f36a0658ffc51c3401"
  license "BSD-2-Clause"

  livecheck do
    url "https://developers.yubico.com/yubico-c/Releases/"
    regex(/href=.*?libyubikey[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
