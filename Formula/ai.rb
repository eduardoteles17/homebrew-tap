class Ai < Formula
  desc "CLI tool for interacting with multiple AI providers"
  homepage "https://github.com/eduardoteles17/ai"
  version "1.0.1"
  license "BSD-3-Clause"

  on_macos do
    on_arm do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.1/ai_1.0.1_darwin_arm64.tar.gz"
      sha256 "9079d071ce8e7b70bf9a9d1aca7bb5bb29b2d82f758b7548cb365d1bbe5756f0"
    end

    on_intel do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.1/ai_1.0.1_darwin_amd64.tar.gz"
      sha256 "0eefd38a9101c789e4017dffc5398027afd2698c2dccf4fdde8cbdac5bb5460f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.1/ai_1.0.1_linux_arm64.tar.gz"
      sha256 "c96f8eb2382c546242559f8ce58bbda54749e0b299cec157c2e3613d8367d171"
    end

    on_intel do
      url "https://github.com/eduardoteles17/ai/releases/download/v1.0.1/ai_1.0.1_linux_amd64.tar.gz"
      sha256 "e8623aec0a80cbe6952a865454c4f628b130adaef86e287f18975828a8d106c1"
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
