#!/usr/bin/env bash

# Function to show usage instructions
__usage() {
    cat <<EOF

Swapfile Creator

This script creates a swapfile with a configurable size and location. By default,
the size is set to 1/4th of the available RAM, and if multiple locations are provided,
the swap is split evenly across all those paths.

Usage: mkswap.sh [-h] [-s SIZE] [-l LOCATIONS...]
Options:
  -h, --help            show this help message and exit
  -s SIZE, --size SIZE  total size of swapfile(s), default is 1/4th of the available RAM
  -l LOCATIONS, --locations LOCATIONS
                        space-separated list of locations for the swapfile(s)

Examples:
  mkswap.sh                # Creates a swapfile with default size in /swapfile
  mkswap.sh -s 4G -l /swapfile1 /swapfile2
  mkswap.sh -l /swapfile    # Creates swapfile in the specified location

EOF
}

# Function to calculate total RAM and 1/4th of it
__get_default_size() {
    local total_ram_kb
    total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    # Convert KB to MB and calculate 1/4th of RAM
    echo $((total_ram_kb / 1024 / 4))
}

# Parse command line arguments
__parse_args() {
    SWAP_SIZE=$( __get_default_size )M  # Default size is 1/4th of RAM
    LOCATIONS=("/swapfile")  # Default swapfile location

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                __usage
                exit 0
                ;;
            -s|--size)
                SWAP_SIZE="$2"
                shift 2
                ;;
            -l|--locations)
                shift
                LOCATIONS=()
                while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                    LOCATIONS+=("$1")
                    shift
                done
                ;;
            *)
                echo "Unknown option: $1"
                __usage
                exit 1
                ;;
        esac
    done
}

# Function to create swapfile at a given location with a given size
__create_swapfile() {
    local location="$1"
    local size="$2"

    echo "Creating swapfile at $location with size $size..."
    # Create the swapfile
    fallocate -l "$size" "$location" || dd if=/dev/zero of="$location" bs=1M count="$size"
    chmod 600 "$location"
    mkswap "$location"
    swapon "$location"
}

# Main logic to distribute swap size across multiple locations
__create_swapfiles() {
    local num_locations=${#LOCATIONS[@]}
    local total_size_mb
    total_size_mb=$(echo "$SWAP_SIZE" | sed 's/[A-Za-z]*//')  # Strip the unit (e.g., M, G)

    local unit=$(echo "$SWAP_SIZE" | sed 's/[0-9]*//')  # Extract unit
    local size_per_location=$((total_size_mb / num_locations))$unit

    for location in "${LOCATIONS[@]}"; do
        __create_swapfile "$location" "$size_per_location"
    done
}

# Main script
__parse_args "$@"
__create_swapfiles
