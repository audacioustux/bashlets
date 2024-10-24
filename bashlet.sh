#!/bin/bash

# Configuration: Define your GitHub repository
GITHUB_REPO="https://github.com/audacioustux/bashlets"
INSTALL_DIR="$HOME/.local/bin"  # Directory to store downloaded files (ensure this is in your $PATH)

# Function to download and install the file
install_bashlet() {
  # Extract script name from argument
  script_path="$1"
  script_name=$(basename "$script_path")
  
  # Download script with .sh appended from GitHub
  download_url="$GITHUB_REPO/$script_path.sh"
  curl -fsSL "$download_url" -o "$INSTALL_DIR/$script_name.sh"
  
  if [ $? -ne 0 ]; then
    echo "Error downloading $script_name.sh from $download_url"
    exit 1
  fi

  # Make the script executable
  chmod +x "$INSTALL_DIR/$script_name.sh"

  # Create symlink without the .sh extension
  ln -s "$INSTALL_DIR/$script_name.sh" "$INSTALL_DIR/$script_name"

  echo "$script_name installed and symlinked to $INSTALL_DIR/$script_name"
}

# Function to execute the script
execute_bashlet() {
  script_path="$1"
  script_name=$(basename "$script_path")

  # Shift arguments to pass to the script
  shift
  "$INSTALL_DIR/$script_name" "$@"
}

# Parse command-line arguments
case "$1" in
  install)
    # Ensure an argument is passed for installation
    if [ -z "$2" ]; then
      echo "Usage: $0 install <path/to/script>"
      exit 1
    fi
    install_bashlet "$2"
    ;;
  exec)
    # Ensure an argument is passed for execution
    if [ -z "$2" ]; then
      echo "Usage: $0 exec <path/to/script> -- <args>"
      exit 1
    fi
    
    # Find '--' to separate the script path from its arguments
    for i in "$@"; do
      if [ "$i" = "--" ]; then
        break
      fi
      shift
    done
    shift  # Remove the '--'
    
    execute_bashlet "$@"
    ;;
  *)
    echo "Usage: $0 {install|exec} <path/to/script> -- <args>"
    exit 1
    ;;
esac
