class Gpgme < Formula
  desc "Library access to GnuPG"
  homepage "https://www.gnupg.org/related_software/gpgme/"
  url "https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.23.2.tar.bz2"
  sha256 "9499e8b1f33cccb6815527a1bc16049d35a6198a6c5fae0185f2bd561bce5224"
  license "LGPL-2.1-or-later"
  revision 1

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/gpgme/"
    regex(/href=.*?gpgme[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "python-setuptools" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "swig" => :build
  depends_on "gnupg"
  depends_on "libassuan"
  depends_on "libgpg-error"

  def python3
    "python3.12"
  end

  def install
    ENV["PYTHON"] = python3
    # HACK: Stop build from ignoring our PYTHON input. As python versions are
    # hardcoded, the Arch Linux patch that changed 3.9 to 3.10 can't detect 3.11
    inreplace "configure", /# Reset everything.*\n\s*unset PYTHON$/, ""

    # Uses generic lambdas.
    # error: 'auto' not allowed in lambda parameter
    ENV.append "CXXFLAGS", "-std=c++14"

    # Use pip over executing setup.py, which installs a deprecated egg distribution
    # https://dev.gnupg.org/T6784
    inreplace "lang/python/Makefile.in",
              /^\s*\$\$PYTHON setup\.py\s*\\/,
              "$$PYTHON -m pip install --use-pep517 #{std_pip_args.join(" ")} . && : \\"

    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--enable-static"
    system "make"
    system "make", "install"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"gpgme-config", prefix, opt_prefix

    # replace libassuan Cellar paths to avoid breakage on libassuan version/revision bumps
    dep_cellar_path_files = [bin/"gpgme-config", lib/"cmake/Gpgmepp/GpgmeppConfig.cmake"]
    inreplace dep_cellar_path_files, Formula["libassuan"].prefix.realpath, Formula["libassuan"].opt_prefix
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gpgme-tool --lib-version")
    system python3, "-c", "import gpg; print(gpg.version.versionstr)"
  end
end
