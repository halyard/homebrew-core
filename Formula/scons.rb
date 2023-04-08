class Scons < Formula
  include Language::Python::Virtualenv

  desc "Substitute for classic 'make' tool with autoconf/automake functionality"
  homepage "https://www.scons.org/"
  url "https://files.pythonhosted.org/packages/e6/a4/c7a1fb8e60067fe4eb5f4bfd13ce9f51bec963dd9a5c50321d8a20b7a3f2/SCons-4.5.2.tar.gz"
  sha256 "813360b2bce476bc9cc12a0f3a22d46ce520796b352557202cb07d3e402f5458"
  license "MIT"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      int main()
      {
        printf("Homebrew");
        return 0;
      }
    EOS
    (testpath/"SConstruct").write "Program('test.c')"
    system bin/"scons"
    assert_equal "Homebrew", shell_output("#{testpath}/test")
  end
end
