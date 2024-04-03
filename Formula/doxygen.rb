class Doxygen < Formula
  desc "Generate documentation for several programming languages"
  homepage "https://www.doxygen.nl/"
  url "https://doxygen.nl/files/doxygen-1.10.0.src.tar.gz"
  mirror "https://downloads.sourceforge.net/project/doxygen/rel-1.10.0/doxygen-1.10.0.src.tar.gz"
  sha256 "dd7c556b4d96ca5e682534bc1f1a78a5cfabce0c425b14c1b8549802686a4442"
  license "GPL-2.0-only"
  head "https://github.com/doxygen/doxygen.git", branch: "master"

  livecheck do
    url "https://www.doxygen.nl/download.html"
    regex(/href=.*?doxygen[._-]v?(\d+(?:\.\d+)+)[._-]src\.t/i)
  end

  depends_on "bison" => :build
  depends_on "cmake" => :build

  uses_from_macos "flex" => :build, since: :big_sur
  uses_from_macos "python" => :build

  fails_with :gcc do
    version "6"
    cause "Need gcc>=7.2. See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66297"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DPYTHON_EXECUTABLE=#{which("python3") || which("python")}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    system "cmake", "-S", ".", "-B", "build", "-Dbuild_doc=1", *std_cmake_args
    man1.install buildpath.glob("build/man/*.1")
  end

  test do
    system bin/"doxygen", "-g"
    system bin/"doxygen", "Doxyfile"
  end
end
