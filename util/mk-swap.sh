#!/usr/bin/env bash

# Function to create swap files
create_swap_files() {
    local count=$1
    local swap_directory=${2:-/var/}
    local swap_file_prefix="swapfile"

    for ((i=1; i<=count; i++)); do
        swap_file="${swap_directory}/${swap_file_prefix}${i}"
        sudo fallocate -l 1G "$swap_file"  # Adjust the size (1G in this example)
        sudo chmod 600 "$swap_file"
        sudo mkswap "$swap_file"
        sudo swapon "$swap_file"

        echo "Swap file $swap_file created and activated."
    done
}

# Function to update /etc/fstab
update_fstab() {
    local swap_directory=${1:-/var/}
    local swap_file_prefix="swapfile"
    
    for swap_file in "${swap_directory}/${swap_file_prefix}"*; do
        echo "$swap_file none swap sw 0 0" | sudo tee -a /etc/fstab
    done

    echo "Updated /etc/fstab to enable swap files."
}

# Main script
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <number_of_swap_files> [swap_directory]"
    exit 1
fi

number_of_swap_files=$1
swap_directory=$2

create_swap_files "$number_of_swap_files" "$swap_directory"
update_fstab "$swap_directory"

echo "Swap setup complete."
