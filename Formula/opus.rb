class Opus < Formula
  desc "Audio codec"
  homepage "https://www.opus-codec.org/"
  url "https://downloads.xiph.org/releases/opus/opus-1.5.1.tar.gz", using: :homebrew_curl
  sha256 "b84610959b8d417b611aa12a22565e0a3732097c6389d19098d844543e340f85"
  license "BSD-3-Clause"

  livecheck do
    url "https://downloads.xiph.org/releases/opus/"
    regex(%r{href=(?:["']?|.*?/)opus[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  head do
    url "https://gitlab.xiph.org/xiph/opus.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-doc", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <opus.h>

      int main(int argc, char **argv)
      {
        int err = 0;
        opus_int32 rate = 48000;
        int channels = 2;
        int app = OPUS_APPLICATION_AUDIO;
        OpusEncoder *enc;
        int ret;

        enc = opus_encoder_create(rate, channels, app, &err);
        if (!(err < 0))
        {
          err = opus_encoder_ctl(enc, OPUS_SET_BITRATE(OPUS_AUTO));
          if (!(err < 0))
          {
             opus_encoder_destroy(enc);
             return 0;
          }
        }
        return err;
      }
    EOS
    system ENV.cxx, "-I#{include}/opus", testpath/"test.cpp",
           "-L#{lib}", "-lopus", "-o", "test"
    system "./test"
  end
end
