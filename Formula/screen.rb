class Screen < Formula
  desc "Terminal multiplexer with VT100/ANSI terminal emulation"
  homepage "https://www.gnu.org/software/screen/"
  license "GPL-3.0-or-later"
  head "https://git.savannah.gnu.org/git/screen.git", branch: "master"

  stable do
    url "https://ftp.gnu.org/gnu/screen/screen-4.9.1.tar.gz"
    mirror "https://ftpmirror.gnu.org/screen/screen-4.9.1.tar.gz"
    sha256 "26cef3e3c42571c0d484ad6faf110c5c15091fbf872b06fa7aa4766c7405ac69"

    # This patch is to disable the error message
    # "/var/run/utmp: No such file or directory" on launch
    patch :p2 do
      url "https://gist.githubusercontent.com/yujinakayama/4608863/raw/75669072f227b82777df25f99ffd9657bd113847/gistfile1.diff"
      sha256 "9c53320cbe3a24c8fb5d77cf701c47918b3fabe8d6f339a00cfdb59e11af0ad5"
    end
  end


  depends_on "autoconf" => :build
  depends_on "automake" => :build

  uses_from_macos "libxcrypt"
  uses_from_macos "ncurses"

  def install
    cd "src" if build.head?

    # Fix error: dereferencing pointer to incomplete type 'struct utmp'
    ENV.append_to_cflags "-include utmp.h"

    # Fix compile with newer Clang
    # https://savannah.gnu.org/bugs/index.php?59465
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1200

    # master branch configure script has no
    # --enable-colors256, so don't use it
    # when `brew install screen --HEAD`
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--infodir=#{info}",
      "--enable-pam",
    ]
    args << "--enable-colors256" unless build.head?

    system "./autogen.sh"
    system "./configure", *args

    system "make"
    system "make", "install"
  end

  test do
    system bin/"screen", "-h"
  end
end
