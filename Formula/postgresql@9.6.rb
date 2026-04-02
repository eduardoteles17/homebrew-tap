class PostgresqlAT96 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v9.6.24/postgresql-9.6.24.tar.bz2"
  sha256 "aeb7a196be3ebed1a7476ef565f39722187c108dd47da7489be9c4fcae982ace"
  license "PostgreSQL"

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2021-11-11", because: :unsupported

  depends_on "pkgconf" => :build

  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"

  depends_on "openssl@3"
  depends_on "readline"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "openldap"
  uses_from_macos "perl"
  uses_from_macos "zlib"

  on_linux do
    depends_on "libxcrypt"
    depends_on "linux-pam"
    depends_on "util-linux"
    depends_on "zlib-ng-compat"
  end

  def install
    ENV.delete "PKG_CONFIG_LIBDIR"
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include} -I#{Formula["readline"].opt_include}"

    # PostgreSQL 9.6 predates C23 where `bool` became a keyword.
    # GCC 15+ defaults to C23, causing `typedef char bool` to fail.
    ENV.append "CFLAGS", "-std=gnu11" if OS.linux?

    # Homebrew's libxml2 >= 2.13 changed xmlStructuredErrorFunc to use const xmlError*.
    # macOS system libxml2 still uses the old non-const signature.
    unless OS.mac?
      inreplace "src/backend/utils/adt/xml.c",
                "xml_errorHandler(void *data, xmlErrorPtr error)",
                "xml_errorHandler(void *data, const xmlError *error)"
    end

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
    args += %w[--with-bonjour --with-tcl] if OS.mac?
    args << "--with-extra-version= (#{tap.user})" if tap

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if OS.mac?

    system "./configure", *args

    # Work around busted path magic in Makefile.global.in. This can't be specified
    # in ./configure, but needs to be set here otherwise install prefixes containing
    # the string "postgres" will get an incorrect pkglibdir.
    # See https://github.com/Homebrew/homebrew-core/issues/62930#issuecomment-709411789
    system "make", "pkglibdir=#{opt_lib}/postgresql",
           "pkgincludedir=#{opt_include}/postgresql",
           "includedir_server=#{opt_include}/postgresql/server"
    system "make", "install-world", "datadir=#{pkgshare}",
           "libdir=#{lib}",
           "pkglibdir=#{lib}/postgresql",
           "includedir=#{include}",
           "pkgincludedir=#{include}/postgresql",
           "includedir_server=#{include}/postgresql/server",
           "includedir_internal=#{include}/postgresql/internal"
    return unless OS.linux?

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

    # Link versioned executables (e.g. psql-9.6, pg_dump-9.6)
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
