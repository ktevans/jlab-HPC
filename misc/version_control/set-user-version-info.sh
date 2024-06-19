#!/bin/bash

# Check if SCRIPT_DIR is defined
if [ -z "$SCRIPT_DIR" ]; then
    echo "The SCRIPT_DIR environment variable is not set."
    read -p "Please enter the directory path or press enter to exit: " user_input
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

# Path to the gitrepos.sh file using SCRIPT_DIR
GITREPO_FILE="${SCRIPT_DIR}/misc/version_control/gitrepos.sh"
# Define the name of the new output file, also within SCRIPT_DIR scope
USER_ENV_VERSION_FILE="${SCRIPT_DIR}/misc/version_control/user_env_version.conf"

# Ensure gitrepos.sh exists
if [ ! -f "$GITREPO_FILE" ]; then
    echo "Error: File $GITREPO_FILE does not exist."
    exit 1
fi

# Source the gitrepos.sh to access repository paths
source "$GITREPO_FILE"

# Fetch the versions of ANAVER and G4VER from the loaded modules
ANAVER=$(module list 2>&1 | grep -oP 'analyzer/\K[^ ]+' || echo "1.7.8")  # Fallback version if not loaded
G4VER=$(module list 2>&1 | grep -oP 'geant4/\K[^ ]+' || echo "11.1.2")    # Fallback version if not loaded

# Function to fetch the latest commit hash of a git repository
fetch_latest_commit() {
    local repo_path="$1"
    if [ ! -d "$repo_path" ]; then
        echo "ERROR: Directory does not exist: $repo_path"
        return ""
    fi
    cd "$repo_path" || return ""
    
    # Check if the directory is a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "WARNING: Not a git repository: $repo_path"
        cd - > /dev/null
        return ""
    fi
    
    # Attempt to get the latest commit hash
    local latest_commit=$(git rev-parse HEAD 2>/dev/null)
    if [ -z "$latest_commit" ]; then
        echo "WARNING: Unable to find the latest commit in $repo_path"
    else
        echo "$latest_commit"
    fi
    
    cd - > /dev/null
}

# Update user_env_version.conf with the latest commit hashes
update_conf() {
    # Fetch latest commit hashes
    local hpc_hash=$(fetch_latest_commit "$HPC_REPO")
    local g4sbs_hash=$(fetch_latest_commit "$G4SBS_REPO")
    local simc_hash=$(fetch_latest_commit "$SIMC_REPO")
    local libsbsdig_hash=$(fetch_latest_commit "$LIBSBSDIG_REPO")
    local sbsoffline_hash=$(fetch_latest_commit "$SBSOFFLINE_REPO")
    local sbs_replay_hash=$(fetch_latest_commit "$SBS_REPLAY_REPO")

    # Write updates to user_env_version.conf
    cat > "$USER_ENV_VERSION_FILE" <<EOF
# This list sets the current user build environment versions for all Hall A analysis software

ANAVER=$ANAVER
G4VER=$G4VER

HPC_HASH=$hpc_hash
G4SBS_HASH=$g4sbs_hash
SIMC_GFORTRAN_HASH=$simc_hash
LIBSBSDIG_HASH=$libsbsdig_hash
SBS_OFFLINE_HASH=$sbsoffline_hash
SBS_REPLAY_HASH=$sbs_replay_hash
EOF
}

# Call the function to update the configuration file
update_conf
echo
echo "$USER_ENV_VERSION_FILE has been updated."
echo
echo "WARNING: ANAVER and G4VER are set with current modules."
echo "   analyzer/ANAVER=analyzer/$ANAVER"
echo "   geant4/G4VER=geant4/$G4VER"
echo "Modify as necessary."
echo
