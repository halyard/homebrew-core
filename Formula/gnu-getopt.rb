class GnuGetopt < Formula
  desc "Command-line option parsing utility"
  homepage "https://github.com/util-linux/util-linux"
  url "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.tar.xz"
  sha256 "d57a626081f9ead02fa44c63a6af162ec19c58f53e993f206ab7c3a6641c2cd7"
  license "GPL-2.0-or-later"

  keg_only :provided_by_macos

  depends_on "asciidoctor" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build

  on_linux do
    keg_only "conflicts with util-linux"
  end

  def install
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--disable-liblastlog2"

    system "make", "getopt", "misc-utils/getopt.1"

    bin.install "getopt"
    man1.install "misc-utils/getopt.1"
    bash_completion.install "bash-completion/getopt"
    doc.install "misc-utils/getopt-example.bash", "misc-utils/getopt-example.tcsh"
  end

  test do
    system "#{bin}/getopt", "-o", "--test"
    # Check that getopt is enhanced
    quiet_system "#{bin}/getopt", "-T"
    assert_equal 4, $CHILD_STATUS.exitstatus
  end
end
