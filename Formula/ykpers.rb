class Ykpers < Formula
  desc "YubiKey personalization library and tool"
  homepage "https://developers.yubico.com/yubikey-personalization/"
  url "https://developers.yubico.com/yubikey-personalization/Releases/ykpers-1.20.0.tar.gz"
  sha256 "0ec84d0ea862f45a7d85a1a3afe5e60b8da42df211bb7d27a50f486e31a79b93"
  license "BSD-2-Clause"
  revision 2

  # https://www.yubico.com/support/terms-conditions/yubico-end-of-life-policy/eol-products/
  deprecate! date: "2025-11-22", because: :unmaintained, replacement_formula: "ykman"
  disable! date: "2026-11-22", because: :unmaintained, replacement_formula: "ykman"

  depends_on "pkgconf" => :build
  depends_on "json-c"
  depends_on "libyubikey"

  on_linux do
    depends_on "libusb"
  end

  # Compatibility with json-c 0.14. Remove with the next release.
  patch do
    url "https://github.com/Yubico/yubikey-personalization/commit/0aa2e2cae2e1777863993a10c809bb50f4cde7f8.patch?full_index=1"
    sha256 "349064c582689087ad1f092e95520421562c70ff4a45e411e86878b63cf8f8bd"
  end
  # Fix device access issues on macOS Catalina and later. Remove with the next release.
  patch do
    url "https://github.com/Yubico/yubikey-personalization/commit/7ee7b1131dd7c64848cbb6e459185f29e7ae1502.patch?full_index=1"
    sha256 "bf3efe66c3ef10a576400534c54fc7bf68e90d79332f7f4d99ef7c1286267d22"
  end

  def install
    # Work around failure from GCC 10+ using default of `-fno-common`
    ENV.append_to_cflags "-fcommon" if ENV.compiler.to_s.start_with?("gcc")

    args = %W[
      --disable-silent-rules
      --with-libyubikey-prefix=#{Formula["libyubikey"].opt_prefix}
    ]
    args << if OS.mac?
      "--with-backend=osx"
    else
      "--with-backend=libusb-1.0"
    end
    system "./configure", *args, *std_configure_args
    system "make", "check"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ykinfo -V 2>&1")
  end
end
