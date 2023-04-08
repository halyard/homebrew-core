class Grep < Formula
  desc "GNU grep, egrep and fgrep"
  homepage "https://www.gnu.org/software/grep/"
  url "https://ftp.gnu.org/gnu/grep/grep-3.10.tar.xz"
  mirror "https://ftpmirror.gnu.org/grep/grep-3.10.tar.xz"
  sha256 "24efa5b595fb5a7100879b51b8868a0bb87a71c183d02c4c602633b88af6855b"
  license "GPL-3.0-or-later"

  depends_on "pkg-config" => :build
  depends_on "pcre2"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-nls
      --prefix=#{prefix}
      --infodir=#{info}
      --mandir=#{man}
      --with-packager=Homebrew
    ]

    args << "--program-prefix=g" if OS.mac?
    system "./configure", *args
    system "make"
    system "make", "install"

    if OS.mac?
      %w[grep egrep fgrep].each do |prog|
        (libexec/"gnubin").install_symlink bin/"g#{prog}" => prog
        (libexec/"gnuman/man1").install_symlink man1/"g#{prog}.1" => "#{prog}.1"
      end
    end

    libexec.install_symlink "gnuman" => "man"
  end

  def caveats
    on_macos do
      <<~EOS
        All commands have been installed with the prefix "g".
        If you need to use these commands with their normal names, you
        can add a "gnubin" directory to your PATH from your bashrc like:
          PATH="#{opt_libexec}/gnubin:$PATH"
      EOS
    end
  end

  test do
    text_file = testpath/"file.txt"
    text_file.write "This line should be matched"

    if OS.mac?
      grepped = shell_output("#{bin}/ggrep -P match #{text_file}")
      assert_match "should be matched", grepped

      grepped = shell_output("#{opt_libexec}/gnubin/grep -P match #{text_file}")
    else
      grepped = shell_output("#{bin}/grep -P match #{text_file}")
    end
    assert_match "should be matched", grepped
  end
end
