# ssh-askpass-mac

ssh-askpass-mac is a graphical password prompt for OpenSSH on macOS, which can store the password in the keychain. It is executed by ssh-add when adding a private key to the ssh-agent:

```
DISPLAY= SSH_ASKPASS=/path/to/ssh-askpass-mac ssh-add -c /path/to/key < /dev/null
```

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/passphrase.png  "Screenshot of ssh-askpass-mac")

It can also be used as a confirmation dialog when accessing a key in the ssh-agent:

![screenshot](https://github.com/lukas-zronek/screenshots/blob/master/ssh-askpass-mac/confirmation.png  "Screenshot of ssh-askpass-mac")

ssh-askpass-mac was inspired by [ksshaskpass](https://github.com/KDE/ksshaskpass) and should behave like the keychain support prior macOS Sierra.

## License

ssh-askpass-mac is released under [BSD 2-Clause License](https://github.com/lukas-zronek/ssh-askpass-mac/blob/master/LICENSE).
