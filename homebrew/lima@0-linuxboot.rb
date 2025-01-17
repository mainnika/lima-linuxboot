class LimaAT0Linuxboot < Formula
  desc "Linux virtual machines"
  homepage "https://github.com/lima-vm/lima"
  url "https://codeload.github.com/mainnika/lima-linuxboot/zip/refs/heads/mainnika/v0.19.1"
  sha256 ""
  license "Apache-2.0"
  head "https://github.com/mainnika/lima-linuxboot.git", branch: "mainnika/v0.19.1"

  depends_on "go" => :build
  # strict dependency on sdk-13 allows brew pass HOMEBREW_SDKROOT as MacOSX13.sdk
  # this is required for lima to build vz driver on macOS Monterey
  depends_on xcode: ["13", :build]

  def install
    if build.head?
      system "make"
    else
      # VERSION has to be explicitly specified when building from tar.gz, as it does not contain git tags
      system "make", "VERSION=#{version}"
    end

    bin.install Dir["_output/bin/*"]
    share.install Dir["_output/share/*"]

    # Install shell completions
    generate_completions_from_executable(bin/"limactl", "completion", base_name: "limactl")
  end

  test do
    info = JSON.parse shell_output("#{bin}/limactl info")
    # Verify that the VM drivers are compiled in
    assert_includes info["vmTypes"], "qemu"
    assert_includes info["vmTypes"], "vz" if OS.mac? && MacOS.version >= :monterey
    # Verify that the template files are installed
    template_names = info["templates"].map { |x| x["name"] }
    assert_includes template_names, "default"
  end
end
