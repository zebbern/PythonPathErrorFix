#!/bin/bash
# =============================================================================
# This script upgrades Python on Linux.
# It ensures that both 'python' and 'python3' commands work correctly.
# If run without root privileges, it will re-launch itself with sudo.
# =============================================================================

# Relaunch with sudo if not running as root.
if [ "$EUID" -ne 0 ]; then
    echo "Not running as root. Relaunching with sudo..."
    exec sudo "$0" "$@"
fi

echo "Running with root privileges."

# Function to check and display Python version
check_python_version() {
    local cmd=$1
    if command -v "$cmd" &>/dev/null; then
        version=$("$cmd" --version 2>&1)
        echo "Found ${cmd}: $version"
    else
        echo "${cmd} not found."
    fi
}

# ---------------------------------------------------------------------------
# Upgrade/Install Python using the appropriate package manager.
# ---------------------------------------------------------------------------
upgrade_python_with_apt() {
    echo "Detected apt-get package manager. Updating repositories..."
    apt-get update
    echo "Upgrading Python3 packages..."
    apt-get upgrade -y python3
    echo "Installing python3 and python-is-python3..."
    apt-get install -y python3 python-is-python3
}

upgrade_python_with_dnf() {
    echo "Detected dnf package manager. Upgrading Python3..."
    dnf upgrade -y python3
    echo "Installing python3..."
    dnf install -y python3
    # Create a symlink for 'python' if needed.
    if ! command -v python &>/dev/null; then
        echo "Creating symlink: python -> $(which python3)"
        ln -sf "$(which python3)" /usr/local/bin/python
    fi
}

upgrade_python_with_yum() {
    echo "Detected yum package manager. Upgrading Python3..."
    yum update -y python3
    echo "Installing python3..."
    yum install -y python3
    if ! command -v python &>/dev/null; then
        echo "Creating symlink: python -> $(which python3)"
        ln -sf "$(which python3)" /usr/local/bin/python
    fi
}

upgrade_python_with_pacman() {
    echo "Detected pacman package manager. Synchronizing and upgrading Python..."
    pacman -Sy --noconfirm python
    if ! command -v python &>/dev/null; then
        echo "Creating symlink: python -> $(which python3)"
        ln -sf "$(which python3)" /usr/local/bin/python
    fi
}

# Check for python3 and python availability before upgrading.
echo "Initial check:"
check_python_version python3
check_python_version python

# Detect the package manager and upgrade Python accordingly.
if command -v apt-get &>/dev/null; then
    upgrade_python_with_apt
elif command -v dnf &>/dev/null; then
    upgrade_python_with_dnf
elif command -v yum &>/dev/null; then
    upgrade_python_with_yum
elif command -v pacman &>/dev/null; then
    upgrade_python_with_pacman
else
    echo "No supported package manager found. Please upgrade Python manually."
    exit 1
fi

# Refresh the command hash table (so that new symlinks/packages are recognized)
hash -r

# Final checks: Display versions for both commands.
echo "Final check:"
check_python_version python3
check_python_version python

echo "Python upgrade process completed."
exit 0
