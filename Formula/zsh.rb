class Zsh < Formula
  desc "UNIX shell (command interpreter)"
  homepage "https://www.zsh.org/"
  license "MIT-Modern-Variant"

  # TODO: Switch to `pcre2` on next release and remove stable block
  stable do
    url "https://downloads.sourceforge.net/project/zsh/zsh/5.9/zsh-5.9.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.9.tar.xz"
    sha256 "9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5"

    depends_on "pcre"
  end

  livecheck do
    url "https://sourceforge.net/projects/zsh/rss?path=/zsh"
  end

  head do
    url "https://git.code.sf.net/p/zsh/code.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "pcre2"
  end

  depends_on "ncurses"

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.9/zsh-5.9-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.9-doc.tar.xz"
    sha256 "6f7c091249575e68c177c5e8d5c3e9705660d0d3ca1647aea365fd00a0bd3e8a"
  end

  def install
    # Fix compile with newer Clang
    # https://www.zsh.org/mla/workers/2020/index.html
    # https://github.com/Homebrew/homebrew-core/issues/64921
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1200

    system "Util/preconfig" if build.head?

    system "./configure", "--prefix=#{prefix}",
           "--enable-fndir=#{pkgshare}/functions",
           "--enable-scriptdir=#{pkgshare}/scripts",
           "--enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions",
           "--enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts",
           "--enable-runhelpdir=#{pkgshare}/help",
           "--enable-cap",
           "--enable-maildir-support",
           "--enable-multibyte",
           "--enable-pcre",
           "--enable-zsh-secure-free",
           "--enable-unicode9",
           "--enable-etcdir=/etc",
           "--with-tcsetpgrp",
           "DL_EXT=bundle"

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
              "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    if build.head?
      # disable target install.man, because the required yodl comes neither with macOS nor Homebrew
      # also disable install.runhelp and install.info because they would also fail or have no effect
      system "make", "install.bin", "install.modules", "install.fns"
    else
      system "make", "install"
      system "make", "install.info"

      resource("htmldoc").stage do
        (pkgshare/"htmldoc").install Dir["Doc/*.html"]
      end
    end
  end

  test do
    assert_equal "homebrew", shell_output("#{bin}/zsh -c 'echo homebrew'").chomp
    system bin/"zsh", "-c", "printf -v hello -- '%s'"
    system bin/"zsh", "-c", "zmodload zsh/pcre"
  end
end
