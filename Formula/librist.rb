class Librist < Formula
  desc "Reliable Internet Stream Transport (RIST)"
  homepage "https://code.videolan.org/rist/"
  url "https://code.videolan.org/rist/librist/-/archive/v0.2.10/librist-v0.2.10.tar.gz"
  sha256 "797e486961cd09bc220c5f6561ca5a08e7747b313ec84029704d39cbd73c598c"
  license "BSD-2-Clause"
  revision 1
  head "https://code.videolan.org/rist/librist.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cjson"
  depends_on "libmicrohttpd"
  depends_on "mbedtls"

  # Add build macos build patch
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
diff --git a/tools/srp_shared.c b/tools/srp_shared.c
index f782126..900db41 100644
--- a/tools/srp_shared.c
+++ b/tools/srp_shared.c
@@ -173,7 +173,11 @@ void user_verifier_lookup(char * username,
 	if (stat(srpfile, &buf) != 0)
 		return;

+#ifdef __APPLE__
+	*generation = ((uint64_t)buf.st_mtimespec.tv_sec << 32) | buf.st_mtimespec.tv_nsec;
+#else
 	*generation = ((uint64_t)buf.st_mtim.tv_sec << 32) | buf.st_mtim.tv_nsec;
+#endif
 #endif

 	if (!lookup_data || !hashversion)
