class Stagenow < Formula
  desc "CLI and daemon to automate Stage Manager per space"
  homepage "https://github.com/GreyElaina/StageNow"
  url "https://github.com/GreyElaina/StageNow/archive/364ed7464b0acf660bb0b135928d00f8e9d759d0.tar.gz"
  version "0.0.0.20250930"
  sha256 "a6913e7002e19d72e6beec2d1fe26da88da28dbf3cff892c137370584d8422a3"
  head "https://github.com/GreyElaina/StageNow.git", branch: "master"

  depends_on xcode: ["14.0", :build]
  depends_on macos: :ventura

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/StageNow"
    pkgshare.install "Resources/config.json"
    pkgshare.install "Resources/Raycast"
  end

  def post_install
    (var/"log/stagenow").mkpath
  end

  def caveats
    <<~EOS
      A sample configuration file is available at:
        #{opt_pkgshare}/config.json

      Recommended: install the user launch agent managed by StageNow (includes MachServices):
        #{opt_bin}/StageNow --install-agent

      Raycast integration scripts are stored in:
        #{opt_pkgshare}/Raycast
      Symlink them into ~/.raycast/scripts if desired.

      If you prefer Homebrew Services, start with the provided plist (includes MachServices):
        brew services start --file=#{opt_pkgshare}/stagenow.mach.plist
      Note: Homebrew's default service template does not include MachServices and
      will not expose the XPC endpoint required by StageNow.
    EOS
  end

  test do
    output = shell_output("#{bin}/StageNow --help")
    assert_match "Stage Manager Controller", output
  end
end
