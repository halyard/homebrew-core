class CAres < Formula
  desc "Asynchronous DNS library"
  homepage "https://c-ares.org/"
  url "https://c-ares.org/download/c-ares-1.28.1.tar.gz"
  mirror "https://github.com/c-ares/c-ares/releases/download/cares-1_17_2/c-ares-1.28.1.tar.gz"
  mirror "http://fresh-center.net/linux/misc/dns/c-ares-1.28.1.tar.gz"
  mirror "http://fresh-center.net/linux/misc/dns/legacy/c-ares-1.28.1.tar.gz"
  sha256 "675a69fc54ddbf42e6830bc671eeb6cd89eeca43828eb413243fd2c0a760809d"
  license "MIT"
  head "https://github.com/c-ares/c-ares.git", branch: "main"

  livecheck do
    url :homepage
    regex(/href=.*?c-ares[._-](\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "cmake" => :build

  def install
    args = %W[
      -DCARES_STATIC=ON
      -DCARES_SHARED=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <ares.h>

      int main()
      {
        ares_library_init(ARES_LIB_INIT_ALL);
        ares_library_cleanup();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lcares", "-o", "test"
    system "./test"

    system "#{bin}/ahost", "127.0.0.1"
  end
end
