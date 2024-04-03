class Unibilium < Formula
  desc "Very basic terminfo library"
  homepage "https://github.com/neovim/unibilium"
  url "https://github.com/neovim/unibilium/archive/refs/tags/v2.1.1.tar.gz"
  sha256 "6f0ee21c8605340cfbb458cbd195b4d074e6d16dd0c0e12f2627ca773f3cabf1"
  license "LGPL-3.0-or-later"

  depends_on "libtool" => :build

  def install
    # Check Homebrew ncurses terminfo if available.
    terminfo_dirs = [Formula["ncurses"].opt_share/"terminfo"]

    terminfo_dirs += if OS.mac?
      [Utils.safe_popen_read("ncurses5.4-config", "--terminfo-dirs").strip]
    else
      # Unibilium's default terminfo path
      %w[
        /etc/terminfo
        /lib/terminfo
        /usr/share/terminfo
        /usr/lib/terminfo
        /usr/local/share/terminfo
        /usr/local/lib/terminfo
      ]
    end

    system "make", "TERMINFO_DIRS=\"#{terminfo_dirs.join(":")}\""
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <unibilium.h>
      #include <stdio.h>

      int main()
      {
        setvbuf(stdout, NULL, _IOLBF, 0);
        unibi_term *ut = unibi_dummy();
        unibi_destroy(ut);
        printf("%s", unibi_terminfo_dirs);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "test.c", "-L#{lib}", "-lunibilium", "-o", "test"
    assert_match %r{\A#{Formula["ncurses"].opt_share}/terminfo:}o, shell_output("./test")
  end
end
