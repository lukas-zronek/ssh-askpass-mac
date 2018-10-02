# ssh-askpass-mac

ssh-askpass-mac is a graphical password prompt for OpenSSH on macOS, which can store the password in the keychain. It is executed by _ssh-add_ when adding encrypted private keys to the ssh-agent:

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase.png  "Screenshot of ssh-askpass-mac")

It can also be used as a confirmation dialog when accessing a key in the ssh-agent:

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/confirmation.png  "Screenshot of ssh-askpass-mac")

ssh-askpass-mac was inspired by [ksshaskpass](https://github.com/KDE/ksshaskpass) and should behave like the keychain support prior to macOS Sierra.

## Building and Installation

**Install Xcode**

You can obtain the latest version of Xcode from the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835)

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
# ssh-askpass-mac
if [ -z ${DISPLAY+x} ]
then
        export DISPLAY=
        launchctl setenv DISPLAY ""
fi
if [ -z ${SSH_ASKPASS+x} ]
then
        export SSH_ASKPASS=/Applications/ssh-askpass.app/Contents/MacOS/ssh-askpass
        launchctl setenv SSH_ASKPASS "$SSH_ASKPASS" && launchctl stop com.openssh.ssh-agent
fi
ssh-add()
{
        command ssh-add $@ < /dev/null
}
```

## License

ssh-askpass-mac is released under [BSD 2-Clause License](https://github.com/lukas-zronek/ssh-askpass-mac/blob/master/LICENSE).
