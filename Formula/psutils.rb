class Psutils < Formula
  include Language::Python::Virtualenv

  desc "Utilities for manipulating PostScript documents"
  homepage "https://github.com/rrthomas/psutils"
  url "https://files.pythonhosted.org/packages/92/07/ebcf289c31f4da85ea94e103f0a58393c54133c64fcbef754c17b6405723/pspdfutils-3.3.2.tar.gz"
  sha256 "a20a2a1359811bd0ad72e15349351a26774ddf8e355c2cde4250a70cf77fdf0c"
  license "GPL-3.0-or-later"
  revision 1

  depends_on "libpaper"
  depends_on "python@3.12"

  resource "puremagic" do
    url "https://files.pythonhosted.org/packages/e0/0b/2308ce51da41b4937375008670346f972316218b9577e4daa75d6077c19e/puremagic-1.21.tar.gz"
    sha256 "31ef09b37a6ad2f7f2b09b5bd6b8c4a07187a01af4025f5f1368889bdfc6d779"
  end

  resource "pypdf" do
    url "https://files.pythonhosted.org/packages/49/6c/4ffb864f1f41b7ef7bf8a397b16888cf191161a98d4c345fa32ec5aa1454/pypdf-4.1.0.tar.gz"
    sha256 "01c3257ec908676efd60a4537e525b89d48e0852bc92b4e0aa4cc646feda17cc"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    resource "homebrew-test-ps" do
      url "https://raw.githubusercontent.com/rrthomas/psutils/e00061c21e114d80fbd5073a4509164f3799cc24/tests/test-files/psbook/3/expected.ps"
      sha256 "bf3f1b708c3e6a70d0f28af55b3b511d2528b98c2a1537674439565cecf0aed6"
    end
    resource("homebrew-test-ps").stage testpath

    expected_psbook_output = "[4] [1] [2] [3] \nWrote 4 pages\n"
    assert_equal expected_psbook_output, shell_output("#{bin}/psbook expected.ps book.ps 2>&1")

    expected_psnup_output = "[1,2] [3,4] \nWrote 2 pages\n"
    assert_equal expected_psnup_output, shell_output("#{bin}/psnup -2 expected.ps nup.ps 2>&1")

    expected_psselect_output = "[1] \nWrote 1 pages\n"
    assert_equal expected_psselect_output, shell_output("#{bin}/psselect -p1 expected.ps test2.ps 2>&1")
  end
end
