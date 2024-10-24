#!/bin/bash

# Exit if any command fails
set -e

# GitHub repo URL (you can modify this to any repo)
GITHUB_REPO="https://github.com/audacioustux/bashlets"

# Ensure the script received exactly one argument (the file path to download)
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file-path>"
    exit 1
fi

# Extract the argument as the file path (e.g. "util/ebort")
FILE_PATH="$1"

# Append .sh to the file path
FILE_NAME=$(basename "$FILE_PATH")
SCRIPT_NAME="${FILE_NAME}.sh"

# Set the target directory where the script should be saved
TARGET_DIR="$HOME/.local/bin"

# Ensure the target directory exists and is part of the user's PATH
mkdir -p "$TARGET_DIR"

# Download the file from the GitHub repository
curl -fsSL "$GITHUB_REPO/raw/main/$FILE_PATH.sh" -o "$TARGET_DIR/$SCRIPT_NAME"

# Make the downloaded script executable
chmod +x "$TARGET_DIR/$SCRIPT_NAME"

# Create a symlink without the .sh extension (inside the same directory)
ln -sf "$TARGET_DIR/$SCRIPT_NAME" "$TARGET_DIR/$FILE_NAME"

# Check if the target directory is in the user's PATH, if not, warn them
if ! echo "$PATH" | grep -q "$TARGET_DIR"; then
    echo "Warning: $TARGET_DIR is not in your PATH. You can add it by running:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

# Output success message
echo "Downloaded and installed '$SCRIPT_NAME' as '$FILE_NAME' in $TARGET_DIR"
