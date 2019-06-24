# ssh-askpass-mac

ssh-askpass-mac is a graphical front-end for _ssh-add_ on macOS, which can store the password of a private key in the keychain. It is executed by _ssh-add_ when adding encrypted private keys to the ssh-agent:

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase.png  "Screenshot of ssh-askpass-mac")

It can also be used as a confirmation dialog when accessing a key in the ssh-agent:

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/confirmation.png  "Screenshot of ssh-askpass-mac")

ssh-askpass-mac was inspired by [ksshaskpass](https://github.com/KDE/ksshaskpass) and should behave like the keychain support prior to macOS Sierra.

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
cp -R build/Release/ssh-askpass.app /Applications
```

## Configuration

Add the following lines to your _.bash_profile_ in your home directory:

```
ssh_askpass_mac=/Applications/ssh-askpass.app/Contents/MacOS/ssh-askpass
export SSH_ASKPASS=$ssh_askpass_mac
if [ -z ${DISPLAY+x} ]
then
        export DISPLAY=
        launchctl setenv DISPLAY ""
fi
ssh_askpass_env=$(launchctl getenv SSH_ASKPASS)
if [ "$ssh_askpass_env" != "$ssh_askpass_mac" ]
then
        launchctl setenv SSH_ASKPASS "$ssh_askpass_mac" && launchctl stop com.openssh.ssh-agent
fi
ssh-add()
{
        command ssh-add $@ < /dev/null
}
```

The setting "Remember passphrase in my keychain" is enabled by default. A change of the setting is retained.
You can also disable the keychain with the following command:

```
defaults write at.zronek.lukas.ssh-askpass useKeychain -bool false
```

## License

ssh-askpass-mac is released under [BSD 2-Clause License](https://github.com/lukas-zronek/ssh-askpass-mac/blob/master/LICENSE).
