class CabalInstall < Formula
  desc "Command-line interface for Cabal and Hackage"
  homepage "https://www.haskell.org/cabal/"
  url "https://hackage.haskell.org/package/cabal-install-3.12.1.0/cabal-install-3.12.1.0.tar.gz"
  sha256 "6848acfd9c726fdcce544a8b669748d0fd9f2da26d28e841069dc4840276b1b2"
  license "BSD-3-Clause"
  head "https://github.com/haskell/cabal.git", branch: "3.12"

  depends_on "ghc"
  uses_from_macos "zlib"

  resource "bootstrap" do
    on_macos do
      on_arm do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.10.3.0/cabal-install-3.10.3.0-aarch64-darwin.tar.xz"
        sha256 "f4f606b1488a4b24c238f7e09619959eed89c550ed8f8478b350643f652dc08c"
      end
      on_intel do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.10.3.0/cabal-install-3.10.3.0-x86_64-darwin.tar.xz"
        sha256 "3aed78619b2164dd61eb61afb024073ae2c50f6655fa60fcc1080980693e3220"
      end
    end
    on_linux do
      on_arm do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.10.3.0/cabal-install-3.10.3.0-aarch64-linux-deb10.tar.xz"
        sha256 "92d341620c60294535f03098bff796ef6de2701de0c4fcba249cde18a2923013"
      end
      on_intel do
        url "https://downloads.haskell.org/~cabal/cabal-install-3.10.3.0/cabal-install-3.10.3.0-x86_64-linux-ubuntu20_04.tar.xz"
        sha256 "b7ccb975bacf8b6a7d6b5dde8a7712787473a149c3dc0ebb2de7fbd00f964844"
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
