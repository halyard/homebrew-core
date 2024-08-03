class Pyyaml < Formula
  desc "YAML framework for Python"
  homepage "https://pyyaml.org"
  url "https://files.pythonhosted.org/packages/cd/e5/af35f7ea75cf72f2cd079c95ee16797de7cd71f29ea7c68ae5ce7be1eda0/PyYAML-6.0.1.tar.gz"
  sha256 "bfdf460b1736c775f2ba9f6a92bca30bc2095067b8a9d77876d1fad6cc3b4a43"
  license "MIT"
  revision 1


  disable! date: "2024-10-06", because: "does not meet homebrew/core's requirements for Python library formulae"

  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "libyaml"

  def pythons
    deps.select { |dep| dep.name.start_with?("python@") }
        .map(&:to_formula)
        .sort_by(&:version)
  end

  def install
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      system python3, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
    end
  end

  def caveats
    python_versions = pythons.map { |p| p.version.major_minor }
                             .map(&:to_s)
                             .join(", ")

    <<~EOS
      This formula provides the `yaml` module for Python #{python_versions}.
      If you need `yaml` for a different version of Python, use pip.

      Additional details on upcoming formula removal are available at:
      * https://github.com/Homebrew/homebrew-core/issues/157500
      * https://docs.brew.sh/Python-for-Formula-Authors#libraries
      * https://docs.brew.sh/Homebrew-and-Python#pep-668-python312-and-virtual-environments
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
