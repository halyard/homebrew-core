class Rbenv < Formula
  desc "Ruby version manager"
  homepage "https://github.com/rbenv/rbenv#readme"
  url "https://github.com/rbenv/rbenv/archive/v1.2.0.tar.gz"
  sha256 "3f3a31b8a73c174e3e877ccc1ea453d966b4d810a2aadcd4d8c460bc9ec85e0c"
  license "MIT"
  head "https://github.com/rbenv/rbenv.git", branch: "master"

  depends_on "ruby-build"

  uses_from_macos "ruby" => :test

  def install
    inreplace "libexec/rbenv" do |s|
      s.gsub! '"${BASH_SOURCE%/*}"/../libexec', libexec
      s.gsub! ":/usr/local/etc/rbenv.d", ":#{HOMEBREW_PREFIX}/etc/rbenv.d\\0" if HOMEBREW_PREFIX.to_s != "/usr/local"
    end

    # Compile optional bash extension.
    system "src/configure"
    system "make", "-C", "src"

    if build.head?
      # Record exact git revision for `rbenv --version` output
      git_revision = Utils.git_short_head
      inreplace "libexec/rbenv---version", /^(version=)"([^"]+)"/,
                                           %Q(\\1"\\2-g#{git_revision}")
    end

    prefix.install ["bin", "completions", "libexec", "rbenv.d"]
  end

  test do
    # Create a fake ruby version and executable.
    rbenv_root = Pathname(shell_output("rbenv root").strip)
    ruby_bin = rbenv_root/"versions/1.2.3/bin"
    foo_script = ruby_bin/"foo"
    foo_script.write "echo hello"
    chmod "+x", foo_script

    # Test versions.
    versions = shell_output("eval \"$(#{bin}/rbenv init -)\" && rbenv versions").split("\n")
    assert_equal 2, versions.length
    assert_match(/\* system/, versions[0])
    assert_equal("  1.2.3", versions[1])

    # Test rehash.
    system "rbenv", "rehash"
    refute_match "Cellar", (rbenv_root/"shims/foo").read
    assert_equal "hello", shell_output("eval \"$(#{bin}/rbenv init -)\" && rbenv shell 1.2.3 && foo").chomp
  end
end
