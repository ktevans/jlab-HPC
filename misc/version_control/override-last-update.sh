#!/bin/bash

# Path to the gitrepos.sh file
GITREPO_FILE="gitrepos.sh"
# Path to the last_update.conf file to be updated
LAST_UPDATE_CONF="last_update.conf"

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
        echo "Directory does not exist: $repo_path"
        return ""
    fi
    cd "$repo_path" || return ""
    local latest_commit=$(git rev-parse HEAD)
    echo "$latest_commit"
    cd - > /dev/null
}

# Update last_update.conf with the latest commit hashes
update_conf() {
    # Fetch latest commit hashes
    local hpc_hash=$(fetch_latest_commit "$HPC_REPO")
    local g4sbs_hash=$(fetch_latest_commit "$G4SBS_REPO")
    local simc_hash=$(fetch_latest_commit "$SIMC_REPO")
    local libsbsdig_hash=$(fetch_latest_commit "$LIBSBSDIG_REPO")
    local sbsoffline_hash=$(fetch_latest_commit "$SBSOFFLINE_REPO")
    local sbs_replay_hash=$(fetch_latest_commit "$SBS_REPLAY_REPO")

    # Write updates to last_update.conf
    cat > "$LAST_UPDATE_CONF" <<EOF
# SSeeds 3.24.24
# This list sets the current build environment versions for all Hall A analysis software

# Last updated on jlab-HPC version <$hpc_hash>

ANAVER=$ANAVER
G4VER=$G4VER

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
echo "last_update.conf has been updated."
echo
echo "WARNING: ANAVER and G4VER are set with current modules."
echo "   analyzer/ANAVER=analyzer/$ANAVER"
echo "   geant4/G4VER=geant4/$G4VER"
echo "Modify as necessary."
echo
