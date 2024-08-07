class Grep < Formula
  desc "GNU grep, egrep and fgrep"
  homepage "https://www.gnu.org/software/grep/"
  url "https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz"
  mirror "https://ftpmirror.gnu.org/grep/grep-3.11.tar.xz"
  sha256 "1db2aedde89d0dea42b16d9528f894c8d15dae4e190b59aecc78f5a951276eab"
  license "GPL-3.0-or-later"

  head do
    url "https://git.savannah.gnu.org/git/grep.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "texinfo" => :build
    depends_on "wget" => :build

    uses_from_macos "gperf" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "pcre2"

  def install
    system "./bootstrap" if build.head?

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
      bin.children.each do |file|
        (libexec/"gnubin").install_symlink file => file.basename.to_s.delete_prefix("g")
      end
      man1.children.each do |file|
        (libexec/"gnuman/man1").install_symlink file => file.basename.to_s.delete_prefix("g")
      end
    end

    (libexec/"gnubin").install_symlink "../gnuman" => "man"
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
