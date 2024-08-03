class Unixodbc < Formula
  desc "ODBC 3 connectivity for UNIX"
  homepage "https://www.unixodbc.org/"
  url "https://www.unixodbc.org/unixODBC-2.3.12.tar.gz"
  mirror "https://fossies.org/linux/privat/unixODBC-2.3.12.tar.gz"
  sha256 "f210501445ce21bf607ba51ef8c125e10e22dffdffec377646462df5f01915ec"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://www.unixodbc.org/download.html"
    regex(/href=.*?unixODBC[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end


  depends_on "libtool"

  conflicts_with "virtuoso", because: "both install `isql` binaries"

  # These conflict with `libiodbc`, which is now keg-only.
  link_overwrite "include/odbcinst.h", "include/sql.h", "include/sqlext.h",
                 "include/sqltypes.h", "include/sqlucode.h"
  link_overwrite "lib/libodbc.a", "lib/libodbc.so"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--enable-static",
                          "--enable-gui=no"
    system "make", "install"
  end

  test do
    system bin/"odbcinst", "-j"
  end
end
