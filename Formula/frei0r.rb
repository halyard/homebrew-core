class Frei0r < Formula
  desc "Minimalistic plugin API for video effects"
  homepage "https://frei0r.dyne.org/"
  url "https://github.com/dyne/frei0r/archive/refs/tags/v2.3.2.tar.gz"
  sha256 "304291e0ecb456a8b054fe04e14adc50ace54d0223b7b29165ff5343e820ef9d"
  license "GPL-2.0-or-later"

  depends_on "cmake" => :build

  def install
    # Disable opportunistic linking against Cairo
    inreplace "CMakeLists.txt", "find_package (Cairo)", ""

    args = %w[
      -DWITHOUT_OPENCV=ON
      -DWITHOUT_GAVL=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <frei0r.h>

      int main()
      {
        int mver = FREI0R_MAJOR_VERSION;
        if (mver != 0) {
          return 0;
        } else {
          return 1;
        }
      }
    EOS
    system ENV.cc, "-L#{lib}", "test.c", "-o", "test"
    system "./test"
  end
end
