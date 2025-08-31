class SoftDelete < Formula
  desc "Safe file deletion utility that moves files to timestamped backup locations"
  homepage "https://github.com/volkovasystems/soft-delete"
  # Version is maintained in /VERSION file - update via deployment scripts
  url "https://github.com/volkovasystems/soft-delete/archive/refs/tags/v#{version}.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "bash" => :recommended

  def install
    bin.install "bin/soft-delete"
  end

  test do
    assert_match "soft-delete version", shell_output("#{bin}/soft-delete --version")
  end
end