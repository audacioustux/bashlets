#!/usr/bin/env bash

# Usage function for help
__usage() {
    cat <<EOF

Bashlet Installer and Executor

Install a script from a GitHub repository and execute it.

Usage: bashlet [-h] install <path/to/script> | exec <path/to/script> -- <args>
Options:
  -h, --help            show this help message and exit

Commands:
  install               install a script from the GitHub repository
  exec                  execute an installed script with arguments

Examples:
  bashlet install util/ebort
  bashlet exec util/ebort -- echo hello

EOF
}

# Parse command line arguments
__parse_args() {
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                __usage
                exit 0
                ;;
            install)
                COMMAND="install"
                SCRIPT_PATH="$2"
                shift 2
                ;;
            exec)
                COMMAND="exec"
                SCRIPT_PATH="$2"
                shift 2
                if [[ "$1" == "--" ]]; then
                    shift
                fi
                EXEC_ARGS=("$@")
                break
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done

    # Validate input
    if [[ -z "$COMMAND" ]]; then
        echo "Missing command (install or exec)" >&2
        exit 1
    fi

    if [[ -z "$SCRIPT_PATH" ]]; then
        echo "Missing script path" >&2
        exit 1
    fi
}

# Function to download and install the file
install_bashlet() {
    local script_path="$1"
    local install_dir="${2:-$HOME/.local/bin}"  # Use provided directory or default to $HOME/.local/bin
    local script_name=$(basename "$script_path")
    
    local github_repo="https://raw.githubusercontent.com/audacioustux/bashlets/main"
    
    # Create the directory if it doesn't exist
    mkdir -p "$install_dir"
    
    # Download the script from GitHub, append .sh
    local download_url="$github_repo/$script_path.sh"
    response_code=$(curl -sSL -w "%{http_code}" "$download_url" -o "$install_dir/$script_name.sh")

    if [[ $response_code -ne 200 ]]; then
        echo "Error downloading $script_name.sh from $download_url"
        exit 1
    fi

    # Make it executable
    chmod +x "$install_dir/$script_name.sh"

    # Create symlink without the .sh extension
    ln -sf "$install_dir/$script_name.sh" "$install_dir/$script_name"

    echo "$script_name installed and symlinked to $install_dir/$script_name"
}

# Function to execute the script
execute_bashlet() {
    local script_path="$1"
    local install_dir="/tmp/bashlet"
    local script_name=$(basename "$script_path")
    
    install_bashlet "$script_path" "$install_dir"
    "$install_dir/$script_name" "${EXEC_ARGS[@]}"
}

# Main logic
__parse_args "$@"

case "$COMMAND" in
    install)
        install_bashlet "$SCRIPT_PATH"
        ;;
    exec)
        execute_bashlet "$SCRIPT_PATH"
        ;;
    *)
        echo "Invalid command: $COMMAND"
        __usage
        exit 1
        ;;
esac
