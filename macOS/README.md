# Setup macOS Sequoia

## Prepare the OS

### Username

1. Select `System Settings...`
2. Select `Users & Groups`
3. Select `Add User`
4. Create a new temporary "Administrator" account.
5. Login as the temporary user.
6. Select `System Settings...`
7. Select `Users & Groups`
8. Right click the user, select `Advanced Options...`
9. Update the `User name` field to have a capital letter.
10. Update the `Home directory` field to have a capital letter.
11. In finder, rename the Home directory to match.
12. Login as the main user.
13. Select `System Settings...`
14. Select `Users & Groups`
15. Select `ⓘ` for the temporary "Administrator" account.
16. Select `Delete User...`
17. Select `Delete the home folder` then `Delete User`
18. Reboot

### Setup

Run the setup script from this repository using the following command:

```shell
curl -fsSL "https://raw.githubusercontent.com/craigsloggett/scripts/refs/heads/macOS/macOS/install.sh" | sh
```

### Homebrew

Install the Homebrew package manager with the following command:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Developer Directory

Create a _Developer_ directory in the `$HOME` folder:

```shell
mkdir -p ~/Developer
```

### Hosts File

Add the configuration and secrets server to `/etc/hosts`:

```shell
sudo vi /etc/hosts
# Add the IP address and hostname to the end of this file.
```

## Configure SSH

First, create an SSH key:

```shell
ssh-keygen -t ed25519
```

Then copy the SSH key to the server containing the rest of the configuration:

```shell
ssh-copy-id user@my-server
```

## Install GnuPG and Import Keys

**Requires:**
 - `ssh`

Install `gnupg` with Homebrew:

```shell
brew install gnupg
```

Copy GPG keys from the server containing the required secret (sub)keys:

```shell
scp user@my-server:/key/directory/secret-subkeys.gpg ~/Desktop
```

Create the configuration directory, then import the GPG keys:

```shell
mkdir -p ~/.local/share/gnupg
chmod 700 ~/.local/share/gnupg
GNUPGHOME=~/.local/share/gnupg gpg --import ~/Desktop/secret-subkeys.gpg
```

## Install Pass and Git Clone the Password Store

**Requires:**
 - `ssh`
 - `gnupg`

Install `pass` with Homebrew:

```shell
brew install pass
```

Clone the password store from the server containing the repository:

```shell
mkdir -p ~/.local/share/pass
chmod 700 ~/.local/share/pass
git clone user@my-server:/pass/directory/password-store.git ~/.local/share/pass
```

Test `pass` works:

```shell
GNUPGHOME=~/.local/share/gnupg PASSWORD_STORE_DIR=~/.local/share/pass pass
```

## Install and Configure Firefox

Install **Firefox** with Homebrew:

```shell
brew install --cask firefox
```

In order to install the Firefox configuration, you need to grant Full Disk Access to Terminal:

`System Settings -> Privacy & Security -> Full Disk Access`

Following this, create a `distribution` folder:

```shell
mkdir /Applications/Firefox.app/Contents/Resources/distribution
```

Copy the `policies.json` file from the configuration server:

```shell
scp user@my-server:/backup/directory/policies.json /Applications/Firefox.app/Contents/Resources/distribution
```

Remove Full Disk Access for the Terminal:

`System Settings -> Privacy & Security -> Full Disk Access`

Firefox will create a profile directory for the user the first time is it opened. This will be overwritten with a `user.js` file with custom configuration. Open Firefox and then close it right away.

Copy the `user.js` file from the configuration server:

```shell
scp user@my-server:/backup/directory/user.js ~/Library/Application\ Support/Firefox/Profiles/*.default-release
```

## System Preferences

### Apple ID

Login and uncheck all iCloud options except for:
 - Reminders
 - Notes

### Wi-Fi

No change

### Bluetooth

No change

### Network

Turn on Firewall

### Notifications

No change

### Sound

No change

### Focus

No change

### Screen Time

No change

### General

#### Software Update

Enable Automatic Updates

### Appearance

No change

### Accessibility

No change

### Control Center

Set Bluetooth to Show in Menu Bar
Set Sound to Always Show in Menu Bar
Set Fast User Switching to Don't Show in Menu Bar
Set Spotlight to Don't Show in Menu Bar

### Privacy & Security

Turn on FileVault

### Desktop & Dock

Adjust size of Dock to be smaller

### Displays

Adjust size of text
