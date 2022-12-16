# ssh-askpass-mac

_ssh-askpass-mac_ is a graphical passphrase dialog for [OpenSSH](https://www.openssh.com) on macOS, which can store the passphrase of a private key in the [keychain](https://support.apple.com/guide/mac-help/use-keychains-to-store-passwords-mchlf375f392/mac). It is intended to be called by the OpenSSH client programs and not invoked directly.

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase-v2.png  "Screenshot of ssh-askpass-mac")

It can also be used as a confirmation dialog when a stored key is accessed after adding the private key with [ssh-add](https://man.openbsd.org/ssh-add.1) using -c argument (recommended):

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/confirmation-v2.png  "Screenshot of ssh-askpass-mac")

ssh-askpass-mac was inspired by [ksshaskpass](https://github.com/KDE/ksshaskpass) and should behave like the keychain support prior to macOS Sierra.

## Security

The passwords are stored in the login keychain by default, which is automatically unlocked when you log in. I recommend creating several keychains and enabling the auto-lock feature. After a password is saved in the login keychain, you can later move it to any other keychain using the keychain app. ssh-askpass-mac will fetch the password automatically from any keychain.

The password is temporarily stored in the memory area of the ssh-askpass-mac app and with the Swift programming language it is not possible to ensure that the memory area is overwritten. A local attacker with administrator rights could read the memory and extract the password.

## Building and Installation

**Install Xcode**

Building requires Xcode 9 or newer. You can obtain the latest version of Xcode from the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835)

**Download**

Open a terminal and run:
```
git clone https://github.com/lukas-zronek/ssh-askpass-mac.git
```

**Compile**
```
cd ssh-askpass-mac
```

```
xcodebuild
```

**Install**

```
mv build/Release/ssh-askpass.app /Applications/
ln -s /Applications/ssh-askpass.app/Contents/Resources/at.zronek.lukas.ssh-askpass.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/at.zronek.lukas.ssh-askpass.plist
```

On macOS < 12 (Monterey) or OpenSSH < 8.4 add the following line to the startup file of your shell (~/.bash_profile (bash) or ~/.zprofile (zsh)):

```
ssh-add()
{
	command ssh-add $@ </dev/null
}
```

Than restart the Terminal app.

## Configuration

The setting "Remember passphrase in my keychain" is enabled by default. A change of the setting is retained.
You can also disable the keychain with the following command:

```
defaults write at.zronek.lukas.ssh-askpass useKeychain -bool false
```

## License

ssh-askpass-mac is released under [BSD 2-Clause License](https://github.com/lukas-zronek/ssh-askpass-mac/blob/master/LICENSE).
