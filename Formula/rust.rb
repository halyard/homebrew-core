class Rust < Formula
  desc "Safe, concurrent, practical language"
  homepage "https://www.rust-lang.org/"

  url "https://static.rust-lang.org/dist/rustc-1.33.0-src.tar.gz"
  sha256 "5a01a8d7e65126f6079042831385e77485fa5c014bf217e9f3e4aff36a485d94"

  depends_on "cmake" => :build
  depends_on "libssh2"
  depends_on "openssl"
  depends_on "pkg-config"

  resource "cargo" do
    url "https://github.com/rust-lang/cargo.git", :tag => "0.34.0",
        :revision => "5c6aa46e6f28661270979696e7b4c2f0dff8628f"
  end

  resource "racer" do
    # Racer should stay < 2.1 for now as 2.1 needs the nightly build of rust
    # See https://github.com/racer-rust/racer/tree/v2.1.19#installation
    url "https://github.com/racer-rust/racer/archive/2.0.14.tar.gz"
    sha256 "0442721c01ae4465843cb73b24f6caa0127c3308d72b944ad75736164756e522"
  end

  resource "cargobootstrap" do
    # From https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
    url "https://static.rust-lang.org/dist/cargo-0.33.0-x86_64-apple-darwin.tar.gz"
    sha256 "25cf75479da383d2307e1d6204e915f628ec3f1c185b124f57839cfd622f54b1"
  end

  def install
    # Fix build failure for compiler_builtins "error: invalid deployment target
    # for -stdlib=libc++ (requires OS X 10.7 or later)"
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version

    # Ensure that the `openssl` crate picks up the intended library.
    # https://crates.io/crates/openssl#manual-configuration
    ENV["OPENSSL_DIR"] = Formula["openssl"].opt_prefix

    # Fix build failure for cmake v0.1.24 "error: internal compiler error:
    # src/librustc/ty/subst.rs:127: impossible case reached" on 10.11, and for
    # libgit2-sys-0.6.12 "fatal error: 'os/availability.h' file not found
    # #include <os/availability.h>" on 10.11 and "SecTrust.h:170:67: error:
    # expected ';' after top level declarator" among other errors on 10.12
    ENV["SDKROOT"] = MacOS.sdk_path

    args = ["--prefix=#{prefix}"]
    args << "--release-channel=stable"
    system "./configure", *args
    system "make"
    system "make", "install"

    resource("cargobootstrap").stage do
      system "./install.sh", "--prefix=#{buildpath}/cargobootstrap"
    end
    ENV.prepend_path "PATH", buildpath/"cargobootstrap/bin"

    resource("cargo").stage do
      ENV["RUSTC"] = bin/"rustc"
      system "cargo", "install", "--root", prefix, "--path", ".", "--features", "curl-sys/force-system-lib-on-osx"
    end

    resource("racer").stage do
      ENV.prepend_path "PATH", bin
      cargo_home = buildpath/"cargo_home"
      cargo_home.mkpath
      ENV["CARGO_HOME"] = cargo_home
      system "cargo", "install", "--root", libexec, "--path", "."
      (bin/"racer").write_env_script(libexec/"bin/racer", :RUST_SRC_PATH => pkgshare/"rust_src")
    end

    # Remove any binary files; as Homebrew will run ranlib on them and barf.
    rm_rf Dir["src/{llvm,llvm-emscripten,test,librustdoc,etc/snapshot.pyc}"]
    (pkgshare/"rust_src").install Dir["src/*"]

    rm_rf prefix/"lib/rustlib/uninstall.sh"
    rm_rf prefix/"lib/rustlib/install.log"
  end

  def post_install
    Dir["#{lib}/rustlib/**/*.dylib"].each do |dylib|
      chmod 0664, dylib
      MachO::Tools.change_dylib_id(dylib, "@rpath/#{File.basename(dylib)}")
      chmod 0444, dylib
    end
  end

  test do
    system "#{bin}/rustdoc", "-h"
    (testpath/"hello.rs").write <<~EOS
      fn main() {
        println!("Hello World!");
      }
    EOS
    system "#{bin}/rustc", "hello.rs"
    assert_equal "Hello World!\n", `./hello`
    system "#{bin}/cargo", "new", "hello_world", "--bin"
    assert_equal "Hello, world!",
                 (testpath/"hello_world").cd { `#{bin}/cargo run`.split("\n").last }
  end
end
