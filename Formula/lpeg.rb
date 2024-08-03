class Lpeg < Formula
  desc "Parsing Expression Grammars For Lua"
  homepage "https://www.inf.puc-rio.br/~roberto/lpeg/"
  url "https://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.1.0.tar.gz"
  mirror "https://github.com/neovim/deps/raw/master/opt/lpeg-1.1.0.tar.gz"
  sha256 "4b155d67d2246c1ffa7ad7bc466c1ea899bbc40fef0257cc9c03cecbaed4352a"
  license "MIT"

  livecheck do
    url :homepage
    regex(/href=.*?lpeg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end


  depends_on "lua" => [:build, :test]
  depends_on "luajit" => [:build, :test]

  def make_install_lpeg_so(luadir, dllflags, abi_version)
    system "make", "LUADIR=#{luadir}", "DLLFLAGS=#{dllflags.join(" ")}", "lpeg.so"
    (share/"lua"/abi_version).install_symlink pkgshare/"re.lua"
    (lib/"lua"/abi_version).install "lpeg.so"
    system "make", "clean"
  end

  def install
    dllflags = %w[-shared -fPIC]
    dllflags << "-Wl,-undefined,dynamic_lookup" if OS.mac?

    luajit = Formula["luajit"]
    lua = Formula["lua"]

    make_install_lpeg_so(luajit.opt_include/"luajit-2.1", dllflags, "5.1")
    make_install_lpeg_so(lua.opt_include/"lua", dllflags, lua.version.major_minor)

    doc.install "lpeg.html", "re.html"
    pkgshare.install "test.lua", "re.lua"
    # Needed by neovim.
    lib.install_symlink lib/"lua/5.1/lpeg.so" => shared_library("liblpeg")
  end

  test do
    system "lua", pkgshare/"test.lua"
    system "luajit", pkgshare/"test.lua"
  end
end
