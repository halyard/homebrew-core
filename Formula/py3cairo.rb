class Py3cairo < Formula
  desc "Python 3 bindings for the Cairo graphics library"
  homepage "https://cairographics.org/pycairo/"
  url "https://github.com/pygobject/pycairo/releases/download/v1.23.0/pycairo-1.23.0.tar.gz"
  sha256 "9b61ac818723adc04367301317eb2e814a83522f07bbd1f409af0dada463c44c"
  license any_of: ["LGPL-2.1-only", "MPL-1.1"]

  depends_on "pkg-config" => :build
  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.11" => [:build, :test]
  depends_on "cairo"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python|
      system python, *Language::Python.setup_install_args(prefix, python), "--install-data=#{prefix}"
    end
  end

  test do
    pythons.each do |python|
      system python, "-c", "import cairo; print(cairo.version)"
    end
  end
end
