class Stagenow < Formula
  desc "CLI and daemon to automate Stage Manager per space"
  homepage "https://github.com/GreyElaina/StageNow"
  url "https://github.com/GreyElaina/StageNow/archive/69416bbe92e118d18c6db264cb5b22ca23336c6c.tar.gz"
  version "0.0.0.20250929"
  sha256 "75b6722f6be1473a6039e864ee059a62df2d25d69c79e308681de4bffec5d7cb"
  head "https://github.com/GreyElaina/StageNow.git", branch: "master"

  depends_on xcode: ["14.0", :build]
  depends_on macos: :ventura

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/StageNow"
    pkgshare.install "Resources/config.json"
    pkgshare.install "Resources/Raycast"

    # Write a custom launchd plist with MachServices for users to start via `brew services --file`
    (pkgshare/"stagenow.mach.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>by.akashina.stagenow</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/StageNow</string>
            <string>--daemon</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <dict>
            <key>SuccessfulExit</key>
            <false/>
          </dict>
          <key>MachServices</key>
          <dict>
            <key>by.akashina.stagenow</key>
            <true/>
          </dict>
          <key>StandardOutPath</key>
          <string>#{var}/log/stagenow/StageManager-daemon.log</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/stagenow/StageManager-daemon.err.log</string>
          <key>EnvironmentVariables</key>
          <dict>
            <key>PATH</key>
            <string>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin</string>
          </dict>
          <key>ProcessType</key>
          <string>Background</string>
        </dict>
      </plist>
    PLIST
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
