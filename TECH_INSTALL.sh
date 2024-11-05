#!/bin/bash

# Define constants
ICC_SYSTEM_DIR="/Library/ColorSync/Profiles"
ICC_USER_DIR="$HOME/Library/ColorSync/Profiles"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # Gets the directory where the script is located
ICC_SOURCE_DIR="$SCRIPT_DIR/ICC" # Folder containing the profiles

# Function to check if a specific profile exists in a directory
check_profile() {
    local directory=$1
    local profile=$2
    if [[ -f "$directory/$profile" ]]; then
        return 0 # Profile exists
    else
        return 1 # Profile does not exist
    fi
}

# Function to copy and install .icc profiles
install_profiles() {
    local source_dir=$1
    local destination=$2
    
    echo "Copying and installing .icc profiles from $source_dir to $destination..."

    # Iterate over each .icc file in the source directory
    shopt -s nullglob # Avoid issues if no .icc files are found
    for profile in "$source_dir"/*.icc; do
        profile_name=$(basename "$profile")
        if ! check_profile "$destination" "$profile_name"; then
            echo "Installing $profile_name..."
            sudo cp "$profile" "$destination/"
        else
            echo "$profile_name is already installed."
        fi
    done
    shopt -u nullglob
}

# Main execution
# Prompt user for installation directory
INSTALL_DIR=$(osascript -e 'tell app "System Events" to display dialog "Choose installation directory" buttons {"System", "User"} default button 2' -e 'button returned of result')
if [[ $INSTALL_DIR == "System" ]]; then
    install_profiles "$ICC_SOURCE_DIR" "$ICC_SYSTEM_DIR"
elif [[ $INSTALL_DIR == "User" ]]; then
    install_profiles "$ICC_SOURCE_DIR" "$ICC_USER_DIR"
else
    echo "Invalid selection. Exiting..."
    exit 1
fi
