class Pygobject3 < Formula
  desc "GNOME Python bindings (based on GObject Introspection)"
  homepage "https://wiki.gnome.org/Projects/PyGObject"
  url "https://download.gnome.org/sources/pygobject/3.46/pygobject-3.46.0.tar.xz"
  sha256 "426008b2dad548c9af1c7b03b59df0440fde5c33f38fb5406b103a43d653cafc"
  license "LGPL-2.1-or-later"
  revision 1

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "gobject-introspection"
  depends_on "py3cairo"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def site_packages(python)
    prefix/Language::Python.site_packages(python)
  end

  def install
    pythons.each do |python|
      xy = Language::Python.major_minor_version(python)
      builddir = "buildpy#{xy}".delete(".")

      system "meson", "setup", builddir, "-Dpycairo=enabled",
                                         "-Dpython=#{python}",
                                         "-Dpython.platlibdir=#{site_packages(python)}",
                                         "-Dpython.purelibdir=#{site_packages(python)}",
                                         *std_meson_args

      system "meson", "compile", "-C", builddir, "--verbose"
      system "meson", "install", "-C", builddir
    end
  end

  test do
    Pathname("test.py").write <<~EOS
      import gi
      gi.require_version("GLib", "2.0")
      assert("__init__" in gi.__file__)
      from gi.repository import GLib
      assert(31 == GLib.Date.get_days_in_month(GLib.DateMonth.JANUARY, 2000))
    EOS

    pythons.each do |python|
      system python, "test.py"
    end
  end
end
