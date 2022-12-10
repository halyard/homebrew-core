class Psutils < Formula
  desc "Collection of PostScript document handling utilities"
  homepage "http://knackered.org/angus/psutils/"
  url "ftp://ftp.knackered.org/pub/psutils/psutils-p17.tar.gz"
  mirror "https://ftp.osuosl.org/pub/blfs/conglomeration/psutils/psutils-p17.tar.gz"
  version "p17"
  sha256 "3853eb79584ba8fbe27a815425b65a9f7f15b258e0d43a05a856bdb75d588ae4"
  license "psutils"

  # This regex is open-ended (i.e., it doesn't contain a trailing delimiter like
  # `\.t`), since the homepage only links to an unversioned archive file
  # (`psutils.tar.gz`) or a versioned archive file with additional trailing text
  # (`psutils-p17-a4-nt.zip`). Relying on the trailing text of the versioned
  # archive file remaining the same could make this check liable to break, so
  # we'll simply leave it looser until/unless it causes a problem.
  livecheck do
    url :homepage
    regex(/href=.*?psutils[._-](p\d+)/i)
  end

  def install
    # This is required, because the makefile expects that its man folder exists
    man1.mkpath
    system "make", "-f", "Makefile.unix",
                         "PERL=/usr/bin/perl",
                         "BINDIR=#{bin}",
                         "INCLUDEDIR=#{pkgshare}",
                         "MANDIR=#{man1}",
                         "install"
  end

  test do
    system "sh", "-c", "#{bin}/showchar Palatino B > test.ps"
    system "#{bin}/psmerge", "-omulti.ps", "test.ps", "test.ps",
      "test.ps", "test.ps"
    system "#{bin}/psnup", "-n", "2", "multi.ps", "nup.ps"
    system "#{bin}/psselect", "-p1", "multi.ps", "test2.ps"
  end
end
