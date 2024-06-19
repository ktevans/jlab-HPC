#!/bin/bash

# Check if SCRIPT_DIR is defined
if [ -z "$SCRIPT_DIR" ]; then
    echo "The SCRIPT_DIR environment variable is not set."
    read -p "Please enter the directory path/to/jlab-HPC or press enter to exit: " user_input
    if [ -z "$user_input" ]; then
        echo "No directory provided. Exiting script..."
        exit 1
    else
        SCRIPT_DIR=$user_input
    fi
fi

# Validate that SCRIPT_DIR points to a directory
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "The path '$SCRIPT_DIR' is not a valid directory. Exiting script..."
    exit 1
fi

# Paths to relevant files and scripts using SCRIPT_DIR environment variable
USER_VERSION_PATH="${SCRIPT_DIR}/misc/version_control/user_env_version.conf"
GITREPOS_FILE="${SCRIPT_DIR}/misc/version_control/gitrepos.sh"
SETUP_GITREPOS_SCRIPT="${SCRIPT_DIR}/misc/version_control/setup-gitrepos.sh"
SET_USER_VERSION_INFO_SCRIPT="${SCRIPT_DIR}/misc/version_control/set-user-version-info.sh"

# Function to check for missing versions or hashes
check_missing_versions() {
    if grep -E '^[A-Z_]+=$' "$USER_VERSION_PATH" > /dev/null; then
        return 0 # True, missing versions/hashes
    else
        return 1 # False, all versions/hashes are present
    fi
}

# Function to check for missing repository paths
check_missing_repos() {
    source "$GITREPOS_FILE"
    if [[ -z $G4SBS_REPO || -z $SIMC_REPO || -z $LIBSBSDIG_REPO || -z $SBSOFFLINE_REPO || -z $SBS_REPLAY_REPO ]]; then
        return 0 # True, missing repos
    else
        return 1 # False, no missing repos
    fi
}

# Begin script logic
# First, check for missing versions or hashes
if check_missing_versions; then
    echo "Missing versions or hashes in $USER_VERSION_PATH."
    # Next, check if any repository paths are missing
    if check_missing_repos; then
        echo "Missing repository paths detected. Executing $SETUP_GITREPOS_SCRIPT."
        $SETUP_GITREPOS_SCRIPT
    fi
    # Update user environment version information
    echo "Updating user environment version information."
    $SET_USER_VERSION_INFO_SCRIPT
else
    echo "All versions and hashes are present in $USER_VERSION_PATH."
fi

# Verify if updates were successful
if check_missing_versions; then
    echo "Warning: Not all versions or hashes could be updated in $USER_VERSION_PATH."
    read -p "Do you want to exit? (yes/no) " decision
    if [[ $decision == "yes" ]]; then
        echo "Exiting script..."
        exit 1
    else
        echo "Continuing without all versions or hashes."
    fi
else
    echo "Verification successful: All versions and hashes are now present."
fi
