class BerkeleyDbAT5 < Formula
  desc "High performance key/value database"
  homepage "https://www.oracle.com/database/technologies/related/berkeleydb.html"
  url "https://download.oracle.com/berkeley-db/db-5.3.28.tar.gz"
  sha256 "e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628"
  license "Sleepycat"
  revision 1

  keg_only :versioned_formula

  # We use a resource to avoid potential build dependency loop in future. Right now this
  # doesn't happen because `perl` depends on `berkeley-db`, but the dependency may change
  # to `berkeley-db@5`. In this case, `automake -> autoconf -> perl` will create a loop.
  # Ref: https://github.com/Homebrew/homebrew-core/issues/100796
  resource "automake" do
    on_linux do
      on_arm do
        url "https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz"
        mirror "https://ftpmirror.gnu.org/automake/automake-1.16.5.tar.xz"
        sha256 "f01d58cd6d9d77fbdca9eb4bbd5ead1988228fdb73d6f7a201f5f8d6b118b469"
      end
    end
  end

  # Fix build with recent clang
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/4c55b1/berkeley-db%404/clang.diff"
    sha256 "86111b0965762f2c2611b302e4a95ac8df46ad24925bbb95a1961542a1542e40"
    directory "src"
  end

  # Further fixes for clang
  patch :p0 do
    url "https://raw.githubusercontent.com/NetBSD/pkgsrc/6034096dc85159a02116524692545cf5752c8f33/databases/db5/patches/patch-src_dbinc_db.in"
    sha256 "302b78f3e1f131cfbf91b24e53a5c79e1d9234c143443ab936b9e5ad08dea5b6"
  end

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff"
    sha256 "83af02f2aa2b746bb7225872cab29a253264be49db0ecebb12f841562d9a2923"
    directory "dist"
  end

  def install
    # BerkeleyDB dislikes parallel builds
    ENV.deparallelize

    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1200

    # Work around ancient config files not recognizing aarch64 linux
    # configure: error: cannot guess build type; you must specify one
    if OS.linux? && Hardware::CPU.arm?
      resource("automake").stage do
        (buildpath/"dist").install "lib/config.guess", "lib/config.sub"
      end
    end

    args = %W[
      --disable-static
      --prefix=#{prefix}
      --mandir=#{man}
      --enable-cxx
      --enable-dbm
    ]

    # BerkeleyDB requires you to build everything from the build_unix subdirectory
    cd "build_unix" do
      system "../dist/configure", *args
      system "make", "install"

      # use the standard docs location
      doc.parent.mkpath
      mv prefix+"docs", doc
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <assert.h>
      #include <string.h>
      #include <db_cxx.h>
      int main() {
        Db db(NULL, 0);
        assert(db.open(NULL, "test.db", NULL, DB_BTREE, DB_CREATE, 0) == 0);

        const char *project = "Homebrew";
        const char *stored_description = "The missing package manager for macOS";
        Dbt key(const_cast<char *>(project), strlen(project) + 1);
        Dbt stored_data(const_cast<char *>(stored_description), strlen(stored_description) + 1);
        assert(db.put(NULL, &key, &stored_data, DB_NOOVERWRITE) == 0);

        Dbt returned_data;
        assert(db.get(NULL, &key, &returned_data, 0) == 0);
        assert(strcmp(stored_description, (const char *)(returned_data.get_data())) == 0);

        assert(db.close(0) == 0);
      }
    EOS
    flags = %W[
      -I#{include}
      -L#{lib}
      -ldb_cxx
    ]
    system ENV.cxx, "test.cpp", "-o", "test", *flags
    system "./test"
    assert_predicate testpath/"test.db", :exist?
  end
end
