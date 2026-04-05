class CabalInstall < Formula
  desc "Command-line interface for Cabal and Hackage"
  homepage "https://www.haskell.org/cabal/"
  license "BSD-3-Clause"
  head "https://github.com/haskell/cabal.git", branch: "3.16"

  stable do
    url "https://hackage.haskell.org/package/cabal-install-3.16.1.0/cabal-install-3.16.1.0.tar.gz"
    sha256 "9d27bc22989f3933486a7bba6ac0a2d8fef16891bf46a973f4d80f429ae95120"

    # Backport HTTP dependency update
    patch :p2 do
      url "https://github.com/haskell/cabal/commit/b49da958030b20554fedfacd612144e836ab3d52.patch?full_index=1"
      sha256 "877b60af7dac4f5a0b5fd96bbdb8bab9407db3f5850264c336b193a42ee092a5"
    end

    # Backport https://github.com/haskell/cabal/commit/3a6a26f826f3a67d9f452418c8cd0daa0ca12d7c
    patch :DATA
  end

  depends_on "ghc" => [:build, :test]
  depends_on "gmp"

  uses_from_macos "libffi"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Make sure bootstrap version supports GHC provided by Homebrew
  resource "bootstrap" do
    on_macos do
      on_arm do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.14.2.0/cabal-install-3.14.2.0-aarch64-darwin.tar.xz"
        sha256 "c599c888c4c72731a2abbbab4c8443f9e604d511d947793864a4e9d7f9dfff83"
      end
      on_intel do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.14.2.0/cabal-install-3.14.2.0-x86_64-darwin.tar.xz"
        sha256 "f9d0cac59deeeb1d35f72f4aa7e5cba3bfe91d838e9ce69b8bc9fc855247ce0f"
      end
    end
    on_linux do
      on_arm do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.14.2.0/cabal-install-3.14.2.0-aarch64-linux-deb10.tar.xz"
        sha256 "63ee40229900527e456bb71835d3d7128361899c14e691cc7024a5ce17235ec3"
      end
      on_intel do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.14.2.0/cabal-install-3.14.2.0-x86_64-linux-ubuntu20_04.tar.xz"
        sha256 "974a0c29cae721a150d5aa079a65f2e1c0843d1352ffe6aedd7594b176c3e1e6"
      end
    end
  end

  def install
    resource("bootstrap").stage buildpath
    cabal = buildpath/"cabal"
    cd "cabal-install" if build.head?
    system cabal, "v2-update"
    system cabal, "v2-install", *std_cabal_v2_args
    bash_completion.install "bash-completion/cabal"
  end

  test do
    system bin/"cabal", "--config-file=#{testpath}/config", "user-config", "init"
    system bin/"cabal", "--config-file=#{testpath}/config", "v2-update"
    system bin/"cabal", "--config-file=#{testpath}/config", "info", "Cabal"
  end
end

__END__
--- a/cabal-install.cabal
+++ b/cabal-install.cabal
@@ -66,7 +66,7 @@ common warnings
 
 common base-dep
     build-depends:
-      , base >=4.13 && <4.22
+      , base >=4.13 && <4.23
 
 common cabal-dep
     build-depends:
