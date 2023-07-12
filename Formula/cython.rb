class Cython < Formula
  desc "Compiler for writing C extensions for the Python language"
  homepage "https://cython.org/"
  url "https://files.pythonhosted.org/packages/38/db/df0e99d6c5fe19ee5c981d22aad557be4bdeed3ecfae25d47b84b07f0f98/Cython-0.29.36.tar.gz"
  sha256 "41c0cfd2d754e383c9eeb95effc9aa4ab847d0c9747077ddd7c0dcb68c3bc01f"
  license "Apache-2.0"

  keg_only <<~EOS
    this formula is mainly used internally by other formulae.
    Users are advised to use `pip` to install cython
  EOS

  depends_on "python@3.11"

  def install
    python = "python3.11"
    ENV.prepend_create_path "PYTHONPATH", libexec/Language::Python.site_packages(python)
    system python, *Language::Python.setup_install_args(libexec, python)

    bin.install (libexec/"bin").children
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])
  end

  test do
    python = Formula["python@3.11"].opt_bin/"python3.11"
    ENV.prepend_path "PYTHONPATH", libexec/Language::Python.site_packages(python)

    phrase = "You are using Homebrew"
    (testpath/"package_manager.pyx").write "print '#{phrase}'"
    (testpath/"setup.py").write <<~EOS
      from distutils.core import setup
      from Cython.Build import cythonize

      setup(
        ext_modules = cythonize("package_manager.pyx")
      )
    EOS
    system python, "setup.py", "build_ext", "--inplace"
    assert_match phrase, shell_output("#{python} -c 'import package_manager'")
  end
end
