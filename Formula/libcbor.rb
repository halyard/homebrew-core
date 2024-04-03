class Libcbor < Formula
  desc "CBOR protocol implementation for C and others"
  homepage "https://github.com/PJK/libcbor"
  url "https://github.com/PJK/libcbor/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "89e0a83d16993ce50651a7501355453f5250e8729dfc8d4a251a78ea23bb26d7"
  license "MIT"

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DWITH_EXAMPLES=OFF", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"example.c").write <<-EOS
    #include "cbor.h"
    #include <stdio.h>
    int main(int argc, char * argv[])
    {
      printf("Hello from libcbor %s\\n", CBOR_VERSION);
      printf("Pretty-printer support: %s\\n", CBOR_PRETTY_PRINTER ? "yes" : "no");
      printf("Buffer growth factor: %f\\n", (float) CBOR_BUFFER_GROWTH);
    }
    EOS

    system ENV.cc, "-std=c99", "example.c", "-L#{lib}", "-lcbor", "-o", "example"
    system "./example"
    puts `./example`
  end
end
