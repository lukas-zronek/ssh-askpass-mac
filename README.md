# ssh-askpass-mac

ssh-askpass-mac is a graphical front-end for [ssh-add](https://man.openbsd.org/ssh-add) on macOS, which can store the password of a private key in the keychain. It is executed by _ssh-add_ when adding encrypted private keys to the ssh-agent:

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase.png  "Screenshot of ssh-askpass-mac")

It can also be used as a confirmation dialog when a stored key is accessed after adding the key with  
_ssh-add -c_ (recommended):

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/confirmation.png  "Screenshot of ssh-askpass-mac")

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
