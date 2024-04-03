class Libssh < Formula
  desc "C library SSHv1/SSHv2 client and server protocols"
  homepage "https://www.libssh.org/"
  url "https://www.libssh.org/files/0.10/libssh-0.10.6.tar.xz"
  sha256 "1861d498f5b6f1741b6abc73e608478491edcf9c9d4b6630eef6e74596de9dc1"
  license "LGPL-2.1-or-later"
  head "https://git.libssh.org/projects/libssh.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "openssl@3"

  uses_from_macos "zlib"

  def install
    mkdir "build" do
      system "cmake", "..", "-DBUILD_STATIC_LIB=ON",
                            "-DWITH_SYMBOL_VERSIONING=OFF",
                            *std_cmake_args
      system "make", "install"
      lib.install "src/libssh.a"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libssh/libssh.h>
      #include <stdlib.h>
      int main()
      {
        ssh_session my_ssh_session = ssh_new();
        if (my_ssh_session == NULL)
          exit(-1);
        ssh_free(my_ssh_session);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", testpath/"test.c",
           "-L#{lib}", "-lssh", "-o", testpath/"test"
    system "./test"
  end
end
