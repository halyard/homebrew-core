class Librist < Formula
  desc "Reliable Internet Stream Transport (RIST)"
  homepage "https://code.videolan.org/rist/"
  url "https://code.videolan.org/rist/librist/-/archive/v0.2.11/librist-v0.2.11.tar.gz"
  sha256 "84e413fa9a1bc4e2607ecc0e51add363e1bc5ad42f7cc5baec7b253e8f685ad3"
  license "BSD-2-Clause"
  revision 1
  compatibility_version 1
  head "https://code.videolan.org/rist/librist.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cjson"
  depends_on "libmicrohttpd"
  depends_on "mbedtls@3"

  # remove brew setup
  patch :DATA

  def install
    ENV.append "LDFLAGS", "-Wl,-rpath,#{rpath}"

    system "meson", "setup", "--default-library", "both", "-Dfallback_builtin=false", *std_meson_args, "build", "."
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_match "Starting ristsender", shell_output("#{bin}/ristsender 2>&1", 1)
  end
end

__END__
diff --git a/meson.build b/meson.build
index 05d00b3..254d0ab 100755
--- a/meson.build
+++ b/meson.build
@@ -39,11 +39,6 @@ deps = []
 platform_files = []
 inc = []
 inc += include_directories('.', 'src', 'include/librist', 'include', 'contrib')
-if (host_machine.system() == 'darwin')
-	r = run_command('brew', '--prefix', check: true)
-	brewoutput = r.stdout().strip()
-	inc += include_directories(brewoutput + '/include')
-endif

 #builtin_lz4 = get_option('builtin_lz4')
 builtin_cjson = get_option('builtin_cjson')
