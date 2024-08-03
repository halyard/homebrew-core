class Opus < Formula
  desc "Audio codec"
  homepage "https://www.opus-codec.org/"
  url "https://ftp.osuosl.org/pub/xiph/releases/opus/opus-1.5.2.tar.gz"
  sha256 "65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1"
  license "BSD-3-Clause"

  livecheck do
    url "https://ftp.osuosl.org/pub/xiph/releases/opus/"
    regex(%r{href=(?:["']?|.*?/)opus[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end


  head do
    url "https://gitlab.xiph.org/xiph/opus.git", branch: "main"

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
