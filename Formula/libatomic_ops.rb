class LibatomicOps < Formula
  desc "Implementations for atomic memory update operations"
  homepage "https://github.com/ivmai/libatomic_ops/"
  url "https://github.com/ivmai/libatomic_ops/releases/download/v7.8.2/libatomic_ops-7.8.2.tar.gz"
  sha256 "d305207fe207f2b3fb5cb4c019da12b44ce3fcbc593dfd5080d867b1a2419b51"
  license all_of: ["GPL-2.0-or-later", "MIT"]

  livecheck do
    url :stable
    strategy :github_latest
  end


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
