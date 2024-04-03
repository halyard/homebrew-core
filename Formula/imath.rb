class Imath < Formula
  desc "Library of 2D and 3D vector, matrix, and math operations"
  homepage "https://www.openexr.com/"
  url "https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/v3.1.11.tar.gz"
  sha256 "9057849585e49b8b85abe7cc1e76e22963b01bfdc3b6d83eac90c499cd760063"
  license "BSD-3-Clause"

  depends_on "cmake" => :build

  # These used to be provided by `ilmbase`
  link_overwrite "lib/libImath.dylib"
  link_overwrite "lib/libImath.so"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~'EOS'
      #include <ImathRoots.h>
      #include <algorithm>
      #include <iostream>

      int main(int argc, char *argv[])
      {
        double x[2] = {0.0, 0.0};
        int n = IMATH_NAMESPACE::solveQuadratic(1.0, 3.0, 2.0, x);

        if (x[0] > x[1])
          std::swap(x[0], x[1]);

        std::cout << n << ", " << x[0] << ", " << x[1] << "\n";
      }
    EOS
    system ENV.cxx, "-std=c++11", "-I#{include}/Imath", "-o", testpath/"test", "test.cpp"
    assert_equal "2, -2, -1\n", shell_output("./test")
  end
end
