class Ai < Formula
  desc "CLI tool for interacting with multiple AI providers"
  homepage "https://github.com/eduardoteles17/ai"
  version "1.0.0"
  license "BSD-3-Clause"

  on_macos do
    on_arm do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.0/ai_1.0.0_darwin_arm64.tar.gz"
      sha256 "2f7948a9382faa37ccf5a8f7c3338565e9e719ca201322fa36ad1511f2df73f4"
    end

    on_intel do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.0/ai_1.0.0_darwin_amd64.tar.gz"
      sha256 "85e6f7a6f0a921662c0d341895a716cfedd7addcfccc909b5435868d8420a86d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.0/ai_1.0.0_linux_arm64.tar.gz"
      sha256 "cb13dbf06fb04bc5b43b909eb09fe1b97e616aa5e49cedd68e070eb34a8b7226"
    end

    on_intel do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.0/ai_1.0.0_linux_amd64.tar.gz"
      sha256 "e357995f637539d1ae29debf4a3ae2e01271cd4a7e3726d691c20a88ecfdf86c"
    end
  end

  def install
    bin.install "ai"

    generate_completions_from_executable(bin/"ai", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ai --version")
  end
end
