class Libvmaf < Formula
  desc "Perceptual video quality assessment based on multi-method fusion"
  homepage "https://github.com/Netflix/vmaf"
  url "https://github.com/Netflix/vmaf/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "7178c4833639e6b989ecae73131d02f70735fdb3fc2c7d84bc36c9c3461d93b1"
  license "BSD-2-Clause-Patent"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "vim" => :build

  on_intel do
    depends_on "nasm" => :build
  end

  def install
    Dir.chdir("libvmaf") do
      system "meson", *std_meson_args, "build"
      system "ninja", "-vC", "build"
      system "ninja", "-vC", "build", "install"
    end
    pkgshare.install "model"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libvmaf/libvmaf.h>
      int main() {
        return 0;
      }
    EOS

    flags = [
      "-I#{HOMEBREW_PREFIX}/include/libvmaf",
      "-L#{lib}",
    ]

    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
