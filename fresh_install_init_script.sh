#! /bin/bash

function install_ruby {
	rbenv install $1
	rbenv local $1
	gem install bundler
}

USER=$1
EMAIL=$2

if [ -z "$2" ]
  then
    echo "Parameters not set, Usage './script \"user\" \"email\"'"
    exit 1
fi

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Take parameters for username and email
## Maybe de tom specific applications

brew tap caskroom/versions
brew tap Yleisradio/terraforms

# Install command line stuff.
brew install git tmux htop vim zsh wget jq jenv rbenv xmlsectool blackbox gnupg terraform chtf pre-commit cfssl

# Install desktop apps.
brew cask install slack sublime-text postman iterm2 gimp whatsapp spotify intellij-idea-ce rubymine docker firefox java java8 spectacle aws-vault shade

# Iterm2
curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

# Ruby >>
rbenv init

eval "$(rbenv init -)"

install_ruby 2.4.2
install_ruby 2.4.4
install_ruby 2.5.3

rbenv global 2.4.2

gem install iStats
gem install mdless
# << Ruby.

# git stuff >>
git config --global user.name $USER
git config --global user.email $EMAIL

## Make unprompted
ssh-keygen -t rsa -b 4096 -C $EMAIL
eval "$(ssh-agent -s)"

## Add to git config `~/.ssh/config`
cat > ~/.ssh/config <<EOL
Host *
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/id_rsa
EOL

ssh-add -K ~/.ssh/id_rsa

# << git stuff.

# Discover all the Java's we setup with brew.
for f in $(ls /Library/Java/JavaVirtualMachines/); do
  jenv add "/Library/Java/JavaVirtualMachines/$f/Contents/Home"
done

# Default use java 11.
jenv global 11.0

# Set terraform version
chtf 0.11.7

## Copy zshrc profile.
cp -f ./zshrc ~/.zshrc

## Window manager shortcuts
cp -f ./spectacle_Shortcuts.json ~/Library/Application Support/Spectacle

## Setup docker memory allocation.
sed -i -e 's/2048/8196/g' ~/Library/Group\ Containers/group.com.docker/settings.json

## Programatically set parameters for macos
defaults write "Apple Global Domain" com.apple.keyboard.fnState -bool true # Switch the fn keys back to function keys.
defaults write "Apple Global Domain" com.apple.swipescrolldirection -bool false # Turn the natural scrolling off.
defaults write "Apple Global Domain" AppleAquaColorVariant -int 6 # Make the window controls grey rather than brightly coloured.
defaults write "Apple Global Domain" AppleInterfaceStyle -string Dark # Dark mode
defaults write "Apple Global Domain" AppleHighlightColor -string "1.000000 0.874510 0.701961"; # Make the highlight colour Orange

# Setup the trackpad
defaults write "com.apple.AppleMultitouchTrackpad" ActuationStrength -int 0
defaults write "com.apple.AppleMultitouchTrackpad" FirstClickThreshold -int 2
defaults write "com.apple.AppleMultitouchTrackpad" SecondClickThreshold -int 2
defaults write "com.apple.AppleMultitouchTrackpad" trackpad.lastselectedtab -int 2


defaults write "com.apple.finder" CreateDesktop false # Hide desktop icons
defaults write "com.apple.menuextra.battery" ShowPercent -string YES # Show battery percentage.

# Setup the dock.
defaults write "com.apple.dock" autohide -bool true
defaults write "com.apple.dock" magnification -bool true
defaults write "com.apple.dock" orientation -string left
defaults write "com.apple.dock" showAppExposeGestureEnabled -bool true
defaults write "com.apple.dock" largesize -int 128
defaults write "com.apple.dock" tilesize -int 16
defaults write "com.apple.dock" persistent-apps -array # Empties the dock out.

# Add volume to wifi, battery, volume, clock to the menu bar. >>
defaults write "com.apple.systemuiserver" "NSStatusItem Visible com.apple.menuextra.volume" -bool true
defaults write "com.apple.systemuiserver" "NSStatusItem Visible com.apple.menuextra.airport" -bool true
defaults write "com.apple.systemuiserver" "NSStatusItem Visible com.apple.menuextra.battery" -bool true

defaults write "com.apple.systemuiserver" menuExtras -array \
"/System/Library/CoreServices/Menu Extras/Clock.menu" \
"/System/Library/CoreServices/Menu Extras/Battery.menu" \
"/System/Library/CoreServices/Menu Extras/AirPort.menu" \
"/System/Library/CoreServices/Menu Extras/Volume.menu"
# <<

# Change the shell.
chsh -s /bin/zsh

# Oh my zsh setup.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Sort theses out. Along with docker setup, sort finder out remove extra stuff.
echo "Now go set the screen resolution, keyboard layout, and wallpaper by hand."
echo "Along with copying the ~/.ssh/id_rsa.pub to github"
