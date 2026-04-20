class TomcatAT9 < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=tomcat/tomcat-9/v9.0.117/bin/apache-tomcat-9.0.117.tar.gz"
  sha256 "f74a0b061e2b0068ec2a17a5e01c250851f6f30f362c8127209a2a6ef7952b29"
  license "Apache-2.0"

  depends_on "openjdk@17"

  def install
    # Remove Windows scripts
    rm Dir["bin/*.bat"]

    # Install files
    libexec.install Dir["*"]

    (bin/"catalina").write_env_script "#{libexec}/bin/catalina.sh",
                                     JAVA_HOME:     Formula["openjdk@17"].opt_prefix,
                                     CATALINA_HOME: libexec

    # Symlink additional scripts
    %w[startup.sh shutdown.sh].each do |script|
      (bin/script.gsub(".sh", "")).write_env_script "#{libexec}/bin/#{script}",
                                                    JAVA_HOME:     Formula["openjdk@17"].opt_prefix,
                                                    CATALINA_HOME: libexec
    end
  end

  def caveats
    <<~EOS
      Configuration files are in:
        #{libexec}/conf

      To start Tomcat:
        catalina start

      To stop Tomcat:
        catalina stop

      The default port is 8080.
    EOS
  end

  service do
    run [opt_bin/"catalina", "run"]
    keep_alive true
  end

  test do
    ENV["CATALINA_HOME"] = libexec
    assert_match "Server version", shell_output("#{bin}/catalina version")
  end
end
