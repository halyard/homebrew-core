class JsonC < Formula
  desc "JSON parser for C"
  homepage "https://github.com/json-c/json-c/wiki"
  url "https://github.com/json-c/json-c/archive/refs/tags/json-c-0.17-20230812.tar.gz"
  version "0.17"
  sha256 "024d302a3aadcbf9f78735320a6d5aedf8b77876c8ac8bbb95081ca55054c7eb"
  license "MIT"
  head "https://github.com/json-c/json-c.git", branch: "master"

  livecheck do
    url :stable
    regex(/^json-c[._-](\d+(?:\.\d+)+)(?:[._-]\d{6,8})?$/i)
  end


  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~'EOS'
      #include <stdio.h>
      #include <json-c/json.h>

      int main() {
        json_object *obj = json_object_new_object();
        json_object *value = json_object_new_string("value");
        json_object_object_add(obj, "key", value);
        printf("%s\n", json_object_to_json_string(obj));
        return 0;
      }
    EOS

    system ENV.cc, "-I#{include}", "test.c", "-L#{lib}", "-ljson-c", "-o", "test"
    assert_equal '{ "key": "value" }', shell_output("./test").chomp
  end
end
