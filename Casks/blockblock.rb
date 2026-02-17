cask "blockblock" do
  version "2.2.2"
  sha256 "4f696c6efbcff1a8e00bf180e53329c04d6225fa7a60c4ea6c55e03dece36669"

  url "https://github.com/objective-see/BlockBlock/releases/download/v#{version}/BlockBlock_#{version}.zip",
      verified: "github.com/objective-see/BlockBlock/"

  name "BlockBlock"
  desc "Monitors common persistence locations"
  homepage "https://objective-see.com/products/blockblock.html"

  installer script: {
    executable: "#{staged_path}/BlockBlock Installer.app/Contents/MacOS/BlockBlock Installer",
    args:       ["-install"],
    sudo:       true,
  }

  uninstall script: {
    executable: "#{staged_path}/BlockBlock Installer.app/Contents/MacOS/BlockBlock Installer",
    args:       ["-uninstall"],
    sudo:       true,
  }

  zap trash: [
    "~/Library/Caches/com.objective-see.blockblock.helper",
    "~/Library/HTTPStorages/com.objective-see.blockblock.helper",
    "~/Library/Preferences/com.objective-see.blockblock.helper.plist",
    "~/Library/Preferences/com.objectiveSee.BlockBlock.plist",
  ]
end
