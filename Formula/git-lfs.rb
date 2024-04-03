class GitLfs < Formula
  desc "Git extension for versioning large files"
  homepage "https://git-lfs.github.com/"
  url "https://github.com/git-lfs/git-lfs/releases/download/v3.5.1/git-lfs-v3.5.1.tar.gz"
  sha256 "fc19c7316e80a6ef674aa4e1863561c1263cd4ce0588b9989e4be9461664d752"
  license "MIT"

  # Upstream creates releases that are sometimes not the latest stable version,
  # so we use the `github_latest` strategy to fetch the release tagged as "latest".
  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "asciidoctor" => :build
  depends_on "go" => :build
  depends_on "ronn" => :build
  depends_on "ruby" => :build

  def install
    ENV["GIT_LFS_SHA"] = ""
    ENV["VERSION"] = version

    system "make"
    system "make", "man", "RONN=#{Formula["ronn"].bin}/ronn"

    bin.install "bin/git-lfs"
    man1.install Dir["man/man1/*.1"]
    man5.install Dir["man/man5/*.5"]
    man7.install Dir["man/man7/*.7"]
    doc.install Dir["man/html/*.html"]
  end

  def caveats
    <<~EOS
      Update your git config to finish installation:

        # Update global git config
        $ git lfs install

        # Update system git config
        $ git lfs install --system
    EOS
  end

  test do
    system "git", "init"
    system "git", "lfs", "track", "test"
    assert_match(/^test filter=lfs/, File.read(".gitattributes"))
  end
end
