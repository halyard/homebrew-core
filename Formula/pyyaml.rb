class Pyyaml < Formula
  desc "YAML framework for Python"
  homepage "https://pyyaml.org"
  url "https://files.pythonhosted.org/packages/cd/e5/af35f7ea75cf72f2cd079c95ee16797de7cd71f29ea7c68ae5ce7be1eda0/PyYAML-6.0.1.tar.gz"
  sha256 "bfdf460b1736c775f2ba9f6a92bca30bc2095067b8a9d77876d1fad6cc3b4a43"
  license "MIT"
  revision 1

  depends_on "cython" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "libyaml"

  def pythons
    deps.select { |dep| dep.name.start_with?("python@") }
        .map(&:to_formula)
        .sort_by(&:version)
  end

  def install
    cythonize = Formula["cython"].bin/"cythonize"
    system cythonize, "yaml/_yaml.pyx"
    pythons.each do |python|
      python_exe = python.opt_libexec/"bin/python"
      system python_exe, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  def caveats
    python_versions = pythons.map { |p| p.version.major_minor }
                             .map(&:to_s)
                             .join(", ")

    <<~EOS
      This formula provides the `yaml` module for Python #{python_versions}.
      If you need `yaml` for a different version of Python, use pip.
    EOS
  end

  test do
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", <<~EOS
        import yaml
        assert yaml.__with_libyaml__
        assert yaml.dump({"foo": "bar"}) == "foo: bar\\n"
      EOS
    end
  end
end
