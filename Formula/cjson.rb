class Cjson < Formula
  desc "Ultralightweight JSON parser in ANSI C"
  homepage "https://github.com/DaveGamble/cJSON"
  url "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.17.tar.gz"
  sha256 "c91d1eeb7175c50d49f6ba2a25e69b46bd05cffb798382c19bfb202e467ec51c"
  license "MIT"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DENABLE_CJSON_UTILS=ON",
                    "-DENABLE_CJSON_TEST=Off",
                    "-DBUILD_SHARED_AND_STATIC_LIBS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <cjson/cJSON.h>

      int main()
      {
        char *s = "{\\"key\\":\\"value\\"}";
        cJSON *json = cJSON_Parse(s);
        if (!json) {
            return 1;
        }
        cJSON *item = cJSON_GetObjectItem(json, "key");
        if (!item) {
            return 1;
        }
        cJSON_Delete(json);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lcjson", "-o", "test"
    system "./test"
  end
end
