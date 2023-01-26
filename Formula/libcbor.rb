class Libcbor < Formula
  desc "CBOR protocol implementation for C and others"
  homepage "https://github.com/PJK/libcbor"
  url "https://github.com/PJK/libcbor/archive/v0.10.1.tar.gz"
  sha256 "e8fa0a726b18861c24428561c80b3c95aca95f468df4e2f3e3ac618be12d3047"
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
