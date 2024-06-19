#!/bin/bash

# Script to check git versions based on paths from setenv.sh

# Path to the setenv.sh file
GITREPO_FILE="gitrepos.sh"

# Check if setenv.sh exists
if [ ! -f "$GITREPO_FILE" ]; then
    echo "Error: File $GITREPO_FILE does not exist."
    exit 1
fi

# Function to check git version
check_git_version() {
    local path="$1"
    echo "Checking git version for: $path"
    
    # Check if the directory exists
    if [ ! -d "$path" ]; then
        echo "Directory does not exist: $path"
        return
    fi

    cd "$path" || return

    # Check if the directory is a git repository by checking if git remote is set up
    if git remote -v > /dev/null 2>&1; then
        # Get the latest commit hash
        local git_version=$(git rev-parse HEAD)
        echo "Latest commit hash: $git_version"
    else
        echo "Not a git repository: $path"
    fi

    cd - > /dev/null
}


# Extract directory paths from setenv.sh
while IFS='=' read -r key value; do
    if [[ $key == export* ]]; then
        # Remove 'export ', trailing spaces, and quotes
        path="${value%\"}"
        path="${path#\"}"
        path="${path// /}" # Remove spaces
        check_git_version "$path"
    fi
done < "$GITREPO_FILE"

