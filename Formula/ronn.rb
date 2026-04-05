class Ronn < Formula
  desc "Builds manuals - the opposite of roff"
  homepage "https://rtomayko.github.io/ronn/"
  url "https://github.com/rtomayko/ronn/archive/refs/tags/0.7.3.tar.gz"
  sha256 "808aa6668f636ce03abba99c53c2005cef559a5099f6b40bf2c7aad8e273acb4"
  license "MIT"
  revision 5

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "groff" => :test

  uses_from_macos "ruby"

  on_linux do
    depends_on "util-linux" => :test # for `col`
  end

  conflicts_with "ronn-ng", because: "both install `ronn` binaries"

  # Fixes "undefined method 'has_rdoc=' for an instance of Gem::Specification"
  # Gemspec was last updated in 2010 and uses deprecated syntax
  patch :DATA

  def install
    ENV["GEM_HOME"] = libexec
    system "gem", "build", "ronn.gemspec"
    system "gem", "install", "ronn-#{version}.gem"
    bin.install libexec/"bin/ronn"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
    man1.install "man/ronn.1"
    man7.install "man/ronn-format.7"
  end

  test do
    (testpath/"test.ronn").write <<~MARKDOWN
      simple(7) -- a simple ronn example
      ==================================

      This document is created by ronn.
    MARKDOWN
    system bin/"ronn", "--date", "1970-01-01", "test.ronn"
    rendered = pipe_output("col -bx", shell_output("groff -t -man -Tascii -P -c test.7"))
    assert_match "SIMPLE(7)", rendered
    assert_match "simple - a simple ronn example", rendered
    assert_match "This document is created by ronn.", rendered
    assert_match "January 1970", rendered
  end
end
__END__
diff --git a/ronn.gemspec b/ronn.gemspec
index 973a9b6..5708a9a 100644
--- a/ronn.gemspec
+++ b/ronn.gemspec
@@ -89,7 +89,6 @@ Gem::Specification.new do |s|
   s.add_dependency 'rdiscount',   '>= 1.5.8'
   s.add_dependency 'mustache',    '>= 0.7.0'

-  s.has_rdoc = true
   s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ronn"]
   s.require_paths = %w[lib]
   s.rubygems_version = '1.1.1'
