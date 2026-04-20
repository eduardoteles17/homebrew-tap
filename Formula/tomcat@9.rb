class TomcatAT9 < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=tomcat/tomcat-9/v9.0.117/bin/apache-tomcat-9.0.117.tar.gz"
  sha256 "f74a0b061e2b0068ec2a17a5e01c250851f6f30f362c8127209a2a6ef7952b29"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/eduardoteles17/homebrew-tap/releases/download/tomcat@9-9.0.117"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "28533279a6b3aa6e50c4fb1a448cdd77bf802d47b819d7c848b809dc4f0aa3b8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c2006b37047601e30b93fd348b57c2ade8424040538c351d699f8ded11fa8c9d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "03fc8d877dd118bb8347ea8f2aff33149b4a871e3d4551f6d02a3dcdbade8300"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f1dd26554403e327190594449af614818114e7c9e39ccb3cabe001af08500aad"
  end

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
