# GPG Keyring Auto-Unlock Setup Guide

Instructions to cleanly initialize a GPG key and seamlessly save its passphrase into a PAM-unlocked `gnome-keyring` on a TTY/Window Manager Linux system.

---

## Phase 1: Environment Preparation

1. Clone this repository onto your new device.
2. Make the script executable and run it:

    chmod +x setup_gpg_keyring.sh
    ./install.sh

---

## Phase 2: Key Creation & Cleanup

1. **Generate your GPG key** (if you don't already have one to import):

    gpg --full-generate-key

2. **Clear the slate:** Before continuing, ensure there are absolutely no pre-existing keyrings confusing the daemon.

    rm -rf ~/.local/share/keyrings/*

---

## Phase 3: The Golden Keyring Chain (Proven Sequence)

Follow these steps exactly to avoid the `login_1` keyring duplication bug:

### 1. Create the Seed Default Keyring
* Trigger a `pinentry` dialog by trying to sign or decrypt a dummy message:

    echo "init" | gpg --clearsign

* Enter your **GPG Passphrase**.
* **CRITICAL:** Check the box that says **"Save in password manager"** (or "Remember password").
* Click **OK**. 
* *(Note: This forces the daemon to generate a catch-all "Default Keyring" file on disk).*

### 2. The TTY Handshake Reboot
* **Reboot the system** and log in via your normal TTY prompt.
* Open your graphical session and launch **Seahorse** (`seahorse`).
* **Observation:** You will notice that logging in via PAM has now cleanly forced the creation of a proper `Login` keyring (padlock open/unlocked), sitting alongside the generic `Default` keyring created in step 1.

### 3. Keyring Alignment
* Inside Seahorse, right-click the **`Login`** keyring and select **"Set as Default"**.
* Right-click the **`Default`** keyring (the older one created in Step 1) and **Delete** it.

### 4. Final Save
* Trigger the pinentry prompt one last time to route the password into your newly set default `Login` keyring:

    echo "test" | gpg --clearsign

* Enter your **GPG Passphrase** and make sure **"Save in password manager"** is checked.
* Click **OK**.

---

## Verification
Reboot your machine completely. Log in via your TTY. Open a terminal and run:

    echo "hello world" | gpg --clearsign

If it signs the text immediately without prompting you for a password, your configuration is flawless.
