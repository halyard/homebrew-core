class PinentryMac < Formula
  desc "Pinentry for GPG on Mac"
  homepage "https://github.com/GPGTools/pinentry"
  url "https://github.com/GPGTools/pinentry/archive/refs/tags/v1.1.1.1.tar.gz"
  sha256 "1a414f2e172cf8c18a121e60813413f27aedde891c5955151fbf8d50c46a9098"
  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later"]
  head "https://github.com/GPGTools/pinentry.git", branch: "master"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on xcode: :build
  depends_on "gettext"
  depends_on "libassuan"
  depends_on :macos

  on_ventura :or_newer do
    depends_on "texinfo" => :build
  end

  def install
    system "autoreconf", "-fiv"
    system "autoconf"
    system "./configure", "--disable-ncurses", "--enable-maintainer-mode"
    system "make"
    prefix.install "macosx/pinentry-mac.app"
    bin.write_exec_script "#{prefix}/pinentry-mac.app/Contents/MacOS/pinentry-mac"
  end

  def caveats
    <<~EOS
      You can now set this as your pinentry program like

      ~/.gnupg/gpg-agent.conf
          pinentry-program #{HOMEBREW_PREFIX}/bin/pinentry-mac
    EOS
  end

  test do
    assert_match version.major_minor_patch.to_s, shell_output("#{bin}/pinentry-mac --version")
  end
end
