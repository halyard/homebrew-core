class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "https://xz.tukaani.org/xz-utils/"
  # The archive.org mirror below needs to be manually created at `archive.org`.
  # GitHub repository has been disabled, so we need to use the mirror.
  # url "https://github.com/tukaani-project/xz/releases/download/v5.4.6/xz-5.4.6.tar.gz"
  url "https://downloads.sourceforge.net/project/lzmautils/xz-5.4.6.tar.gz"
  mirror "https://archive.org/download/xz-5.4.6/xz-5.4.6.tar.gz"
  mirror "http://archive.org/download/xz-5.4.6/xz-5.4.6.tar.gz"
  sha256 "aeba3e03bf8140ddedf62a0a367158340520f6b384f75ca6045ccc6c0d43fd5c"
  license all_of: [
    :public_domain,
    "GPL-2.0-or-later",
  ]
  version_scheme 1

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules", "--disable-nls"
    system "make", "check"
    system "make", "install"
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.xz
    system bin/"xz", path
    refute_predicate path, :exist?

    # decompress: data.txt.xz -> data.txt
    system bin/"xz", "-d", "#{path}.xz"
    assert_equal original_contents, path.read

    # Check that http mirror works
    xz_tar = testpath/"xz.tar.gz"
    stable.mirrors.each do |mirror|
      next if mirror.start_with?("https")

      xz_tar.unlink if xz_tar.exist?
      system "curl", "--location", mirror, "--output", xz_tar
      assert_equal stable.checksum.hexdigest, xz_tar.sha256
    end
  end
end
