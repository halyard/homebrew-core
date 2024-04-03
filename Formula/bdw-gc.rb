class BdwGc < Formula
  desc "Garbage collector for C and C++"
  homepage "https://www.hboehm.info/gc/"
  url "https://github.com/ivmai/bdwgc/releases/download/v8.2.6/gc-8.2.6.tar.gz"
  sha256 "b9183fe49d4c44c7327992f626f8eaa1d8b14de140f243edb1c9dcff7719a7fc"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  head do
    url "https://github.com/ivmai/bdwgc.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  depends_on "libatomic_ops" => :build
  depends_on "pkg-config" => :build

  on_linux do
    depends_on "gcc" => :test
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-cplusplus",
                          "--enable-static",
                          "--enable-large-config"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <stdio.h>
      #include "gc.h"

      int main(void)
      {
        int i;

        GC_INIT();
        for (i = 0; i < 10000000; ++i)
        {
          int **p = (int **) GC_MALLOC(sizeof(int *));
          int *q = (int *) GC_MALLOC_ATOMIC(sizeof(int));
          assert(*p == 0);
          *p = (int *) GC_REALLOC(q, 2 * sizeof(int));
        }
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lgc", "-o", "test"
    system "./test"
  end
end
