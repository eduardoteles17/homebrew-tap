class PostgresqlAT94 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v9.4.26/postgresql-9.4.26.tar.bz2"
  sha256 "f5c014fc4a5c94e8cf11314cbadcade4d84213cfcc82081c9123e1b8847a20b9"
  license "PostgreSQL"

  bottle do
    root_url "https://github.com/eduardoteles17/homebrew-tap/releases/download/postgresql@9.4-9.4.26"
    sha256 x86_64_linux: "851fcb8a0b8371da1266bc932c301d7eeb17fde72969ea1230e83dd97ae76823"
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2020-02-13", because: :unsupported

  depends_on "pkgconf" => :build

  depends_on "krb5"
  depends_on "libxcrypt"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on :linux
  depends_on "linux-pam"
  depends_on "openldap"
  depends_on "openssl@3"
  depends_on "perl"
  depends_on "readline"
  depends_on "util-linux"
  depends_on "zlib-ng-compat"

  def install
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"

    # PostgreSQL 9.4 configure tests use implicit int main(), which is
    # invalid in C99+. Modern compilers (GCC 15 / Clang 16+) reject this.
    # Use gnu89 for configure, then switch to gnu11 for the actual build
    # (needed on Linux to avoid C23 `bool` keyword conflict).
    ENV.append "CFLAGS", "-std=gnu89"

    # Homebrew's libxml2 >= 2.13 changed xmlStructuredErrorFunc to use const xmlError*.
    inreplace "src/backend/utils/adt/xml.c",
              "xml_errorHandler(void *data, xmlErrorPtr error)",
              "xml_errorHandler(void *data, const xmlError *error)"

    # Modern OpenLDAP removed the separate ldap_r (thread-safe) library,
    # merging it into ldap.
    inreplace "configure", "-lldap_r", "-lldap"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{opt_pkgshare}
      --libdir=#{opt_lib}
      --includedir=#{opt_include}
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --enable-thread-safety
      --with-gssapi
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-pam
      --with-perl
      --with-uuid=e2fs
    ]
    args << "--with-extra-version= (#{tap.user})" if tap

    system "./configure", *args

    # Switch from gnu89 (needed for configure) to gnu11 (needed for build)
    ENV["CFLAGS"] = ENV["CFLAGS"].sub("-std=gnu89", "-std=gnu11")

    # Work around busted path magic in Makefile.global.in. This can't be specified
    # in ./configure, but needs to be set here otherwise install prefixes containing
    # the string "postgres" will get an incorrect pkglibdir.
    # See https://github.com/Homebrew/homebrew-core/issues/62930#issuecomment-709411789
    system "make", "pkglibdir=#{opt_lib}/postgresql",
           "pkgincludedir=#{opt_include}/postgresql",
           "includedir_server=#{opt_include}/postgresql/server"
    # Skip install-world (requires SGML tools for docs).
    # Install src, contrib, and config separately.
    install_args = %W[
      datadir=#{pkgshare}
      libdir=#{lib}
      pkglibdir=#{lib}/postgresql
      includedir=#{include}
      pkgincludedir=#{include}/postgresql
      includedir_server=#{include}/postgresql/server
      includedir_internal=#{include}/postgresql/internal
    ]
    %w[install-world-src-recurse install-world-contrib-recurse install-world-config-recurse].each do |target|
      system "make", target, *install_args
    end

    inreplace lib / "postgresql/pgxs/src/Makefile.global",
              "LD = #{Superenv.shims_path}/ld",
              "LD = #{HOMEBREW_PREFIX}/bin/ld"
  end

  def post_install
    (var / "log").mkpath
    postgresql_datadir.mkpath

    # Manually link files from keg to non-conflicting versioned directories in HOMEBREW_PREFIX.
    # share uses #{name} subdir, while include/lib use "postgresql" subdir.
    { "include" => "postgresql", "lib" => "postgresql", "share" => name }.each do |dir, subdir|
      dst_dir = HOMEBREW_PREFIX / dir / name
      src_dir = prefix / dir / subdir
      next unless src_dir.exist?

      src_dir.find do |src|
        dst = dst_dir / src.relative_path_from(src_dir)

        # Retain existing real directories for extensions if directory structure matches
        next if dst.directory? && !dst.symlink? && src.directory? && !src.symlink?

        rm_r(dst) if dst.exist? || dst.symlink?
        if src.symlink? || src.file?
          Find.prune if src.basename.to_s == ".DS_Store"
          dst.parent.install_symlink src
        elsif src.directory?
          dst.mkpath
        end
      end
    end

    # Link versioned executables (e.g. psql-9.4, pg_dump-9.4)
    bin.each_child { |f| (HOMEBREW_PREFIX / "bin").install_symlink f => "#{f.basename}-#{version.major_minor}" }

    # Don't initialize database, it clashes when testing other PostgreSQL versions.
    return if ENV["HOMEBREW_GITHUB_ACTIONS"]

    system bin / "initdb", "--locale=C", "-E", "UTF-8", postgresql_datadir unless pg_version_exists?
  end

  def postgresql_datadir
    var / name
  end

  def postgresql_log_path
    var / "log/#{name}.log"
  end

  def pg_version_exists?
    (postgresql_datadir / "PG_VERSION").exist?
  end

  def caveats
    <<~EOS
      This formula has created a default database cluster with:
        initdb --locale=C -E UTF-8 #{postgresql_datadir}

      When uninstalling, some dead symlinks are left behind so you may want to run:
        brew cleanup --prune-prefix
    EOS
  end

  service do
    run [opt_bin / "postgres", "-D", f.postgresql_datadir]
    environment_variables LC_ALL: "C"
    keep_alive true
    log_path f.postgresql_log_path
    error_log_path f.postgresql_log_path
    working_dir HOMEBREW_PREFIX
  end

  test do
    system bin / "initdb", testpath / "test" unless ENV["HOMEBREW_GITHUB_ACTIONS"]
    [bin / "pg_config", HOMEBREW_PREFIX / "bin/pg_config-#{version.major_minor}"].each do |pg_config|
      assert_equal opt_pkgshare.to_s, shell_output("#{pg_config} --sharedir").chomp
      assert_equal opt_lib.to_s, shell_output("#{pg_config} --libdir").chomp
      assert_equal (opt_lib / "postgresql").to_s, shell_output("#{pg_config} --pkglibdir").chomp
      assert_equal (opt_include / "postgresql").to_s, shell_output("#{pg_config} --pkgincludedir").chomp
      assert_equal (opt_include / "postgresql/server").to_s, shell_output("#{pg_config} --includedir-server").chomp
    end
  end
end
