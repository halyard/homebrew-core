class Texinfo < Formula
  desc "Official documentation format of the GNU project"
  homepage "https://www.gnu.org/software/texinfo/"
  url "https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/texinfo/texinfo-7.1.tar.xz"
  sha256 "deeec9f19f159e046fdf8ad22231981806dac332cc372f1c763504ad82b30953"
  license "GPL-3.0-or-later"


  uses_from_macos "ncurses"
  uses_from_macos "perl"

  on_system :linux, macos: :high_sierra_or_older do
    depends_on "gettext"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-install-warnings",
                          "--prefix=#{prefix}"
    system "make", "install"
    doc.install Dir["doc/refcard/txirefcard*"]
  end

  def post_install
    info_dir = HOMEBREW_PREFIX/"share/info/dir"
    info_dir.delete if info_dir.exist?
    info_dir.dirname.glob("*.info") do |f|
      quiet_system("#{bin}/install-info", "--quiet", f, info_dir)
    end
  end

  test do
    (testpath/"test.texinfo").write <<~EOS
      @ifnottex
      @node Top
      @top Hello World!
      @end ifnottex
      @bye
    EOS

    system bin/"makeinfo", "test.texinfo"
    assert_match "Hello World!", (testpath/"test.info").read
  end
end
