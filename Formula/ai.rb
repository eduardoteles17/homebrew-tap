class Ai < Formula
  desc "CLI tool for interacting with multiple AI providers"
  homepage "https://github.com/eduardoteles17/ai"
  version "1.0.1"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/eduardoteles17/homebrew-tap/releases/download/ai-1.0.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "295c1093e66f3b3bbfd5c785af14e524e38deec29df3fed9cf6131e14e17270b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ae3c75f1bd6c416bcd7aa583c0bc7d6b6660b6b2410843b70e3fde05a05a23e8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "5f4235d35250975706db8299445549d74a2b93c33f0068c7d5f325681a84954b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "12a3e6e5a34d1b02af3f0c0ada48ca1959b524d12758ede216d5cc80feed0ee5"
  end

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
