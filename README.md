# ssh-askpass-mac

_ssh-askpass-mac_ is a graphical passphrase dialog for [OpenSSH](https://www.openssh.com) on macOS, which can store the passphrase of a private key in the [keychain](https://support.apple.com/guide/mac-help/use-keychains-to-store-passwords-mchlf375f392/mac). It is intended to be called by the OpenSSH client programs and not invoked directly.

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase-v3.png  "Screenshot of ssh-askpass-mac")

It can also be used as a confirmation dialog when adding the private key to the [ssh-agent](https://man.openbsd.org/ssh-agent.1) with [ssh-add -c](https://man.openbsd.org/ssh-add.1) (recommended):

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/confirmation-v3.png  "Screenshot of ssh-askpass-mac")

ssh-askpass-mac was inspired by [ksshaskpass](https://github.com/KDE/ksshaskpass) and should behave like the keychain support prior to macOS Sierra.

## Demo

![](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase-demo-v3.webp  "Demo of ssh-askpass-mac")

## Installation

- Download and unzip the latest version from the [release page](https://github.com/lukas-zronek/ssh-askpass-mac/releases).
- Drag and drop _ssh-askpass.app_ into the Applications folder.
- Control-click the app icon, then choose Open from the menu.
- Click Open to permently add the app as an exception to your security settings.
- Open a terminal app and run:
```
ln -s /Applications/ssh-askpass.app/Contents/Resources/at.zronek.lukas.ssh-askpass.plist ~/Library/LaunchAgents/ && launchctl load -w ~/Library/LaunchAgents/at.zronek.lukas.ssh-askpass.plist
```
- Restart the terminal app

## Building

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

Than restart the Terminal app.

On macOS < 12 (Monterey) or OpenSSH < 8.4 add the following line to the startup file of your shell (~/.bash_profile (bash) or ~/.zprofile (zsh)):

```
ssh-add()
{
	command ssh-add $@ </dev/null
}
```

## Configuration

The setting "Remember passphrase in my keychain" is enabled by default. A change of the setting is retained.
You can also disable the keychain with the following command:

```
defaults write at.zronek.lukas.ssh-askpass useKeychain -bool false
```

## How it works

OpenSSH launches any program that is located in the environment variable SSH_ASKPASS when an input is needed, e.g. passphrase for private key. The program's STDIO is used as input by OpenSSH.

Based on the text that OpenSSH passes as the first argument and the environment variable SSH_ASKPASS_PROMPT, ssh-askpass-mac determines what kind of dialog should be displayed.

To ensure that SSH_ASKPASS is set globally including for built-in ssh-agent, the Launch Agent is required.

## Security

Passphrases are stored in the macOS login keychain by default. The user can choose to always allow access to the keychain item, which is not recommended. In this case, the app is permanently trusted and given access to the keychain item in the future without asking the user again.

The Keychain Access app can be used to create a custom keychain and enable auto-lock. After a passphrase is saved in the login keychain, the item can later be moved to another keychain using the Keychain Access app. ssh-askpass-mac will automatically fetch the passphrase from any keychain.

The passhprase is temporarily stored in the memory area of the ssh-askpass-mac app and with the Swift programming language it is not possible to ensure that the memory area is overwritten. A local attacker with administrator rights could read the memory and extract the password.

## Notes

If [Secure Keyboard Entry](https://support.apple.com/guide/terminal/use-secure-keyboard-entry-trml109/mac) in the Terminal.app is enabled, _ssh-askpass-mac_ (and other apps launched from the Terminal.app) can not grab focus. The focus remains on the Terminal.app window, until the user clicks on the _ssh-askpass-mac_ window.

## License

ssh-askpass-mac is released under [BSD 2-Clause License](https://github.com/lukas-zronek/ssh-askpass-mac/blob/master/LICENSE).
