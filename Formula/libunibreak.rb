class Libunibreak < Formula
  desc "Implementation of the Unicode line- and word-breaking algorithms"
  homepage "https://github.com/adah1972/libunibreak"
  url "https://github.com/adah1972/libunibreak/releases/download/libunibreak_6_1/libunibreak-6.1.tar.gz"
  sha256 "cc4de0099cf7ff05005ceabff4afed4c582a736abc38033e70fdac86335ce93f"
  license "Zlib"

  livecheck do
    url :stable
    regex(/v?(\d+(?:[_-]\d+)+)$/i)
    strategy :git do |tags|
      tags.map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <unibreakbase.h>
      #include <linebreak.h>
      #include <assert.h>
      #include <stdlib.h>
      #include <string.h>
      int main() {
        static const utf8_t input[] = "test\\nstring \xF0\x9F\x98\x8A test";
        char output[sizeof(input) - 1];
        static const char expected[] = {
          2, 2, 2, 2, 0,
          2, 2, 2, 2, 2, 2, 1,
          3, 3, 3, 2, 1,
          2, 2, 2, 4
        };

        assert(sizeof(output) == sizeof(expected));

        init_linebreak();
        set_linebreaks_utf8(input, sizeof(output), NULL, output);

        return memcmp(output, expected, sizeof(output)) != 0;
      }
    EOS
    system ENV.cc, "-o", "test", "test.c", "-I#{include}",
                   "-L#{lib}", "-lunibreak"
    system "./test"
  end
end
