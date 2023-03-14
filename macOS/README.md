Setup macOS
===========

## Prepare the OS

### Username

 1. Select `System Settings...`
 2. Select `Users & Groups`
 3. Select `Add Account`
 4. Create a new temporary "Administrator" account.
 5. Login as the temporary user.
 6. Select `System Settings...`
 7. Select `Users & Groups`
 8. Right click the user, select `Advanced Options...`
 9. Update the `User name` field to have a capital letter.
 10. Update the `Home directory` field to have a capital letter.
 11. In finder, rename the Home directory to match.

### Homebrew

Install the Homebrew package manager with the following command:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Configure SSH
 1. Create an SSH Key
   - $ ssh-keygen -t ed25519
 2. Copy SSH Key to Server
   - $ ssh-copy-id user@my-server-ip
