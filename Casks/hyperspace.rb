cask 'hyperspace' do
  version '2.3.1'
  sha256 '1d5f0fccc1c8a507a16d66be49569fceea291ed7d7bbaa05ff43bc43536229fa'

  url "https://github.com/nickzman/hyperspace/releases/download/v#{version}/Hyperspace#{version}.dmg"
  homepage 'https://github.com/nickzman/hyperspace'
  name 'Hyperspace'

  screen_saver 'Hyperspace.saver'
end
