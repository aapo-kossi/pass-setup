#!/usr/bin/env bash

# Exit on fail
set -e

echo "===================================================="
echo " Starting GPG & GNOME Keyring Setup Script"
echo "===================================================="

# 1. Install Dependencies
echo "--> Installing dependencies..."
if [ -x "$(command -v pacman)" ]; then
    sudo pacman -S --needed gnupg gnome-keyring seahorse pinentry
elif [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update
    sudo apt-get install -y gnupg gnome-keyring seahorse pinentry-gnome3
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf install -y gnupg gnome-keyring seahorse pinentry-gnome3
else
    echo "❌ Unknown package manager. Please install gnupg, gnome-keyring, seahorse, and pinentry manually."
    exit 1
fi

# 2. Configure GPG Agent
echo "--> Configuring ~/.gnupg/gpg-agent.conf..."
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Determine the correct pinentry binary path
if [ -f /usr/bin/pinentry-gnome3 ]; then
    PINENTRY_PATH="/usr/bin/pinentry-gnome3"
elif [ -f /usr/bin/pinentry-gnome ]; then
    PINENTRY_PATH="/usr/bin/pinentry-gnome"
else
    PINENTRY_PATH="/usr/bin/pinentry"
fi

cat << EOF > ~/.gnupg/gpg-agent.conf
allow-preset-passphrase
pinentry-program $PINENTRY_PATH
EOF

# Reload GPG Agent
gpg-connect-agent reloadagent /bye

# 3. Inject PAM configuration safely if not already present
echo "--> Checking PAM configuration in /etc/pam.d/login..."
if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/login; then
    echo "⚠️ Visual check required: Appending GNOME Keyring to /etc/pam.d/login"
    echo "   (You may want to verify the exact order in the file later)"
    
    sudo bash -c 'cat << EOF >> /etc/pam.d/login

# GNOME Keyring integration
auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start
password   optional     pam_gnome_keyring.so
EOF'
else
    echo "✅ PAM configuration already contains pam_gnome_keyring.so."
fi

echo "===================================================="
echo " Script Phase Finished!"
echo " Next: Proceed with the manual configuration steps."
echo "===================================================="

