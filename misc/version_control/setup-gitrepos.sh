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

# Define the paths to your files using SCRIPT_DIR
SETENV_FILE="$SCRIPT_DIR/setenv.sh"
GITREPOS_FILE="$SCRIPT_DIR/misc/version_control/gitrepos.sh"

# Ensure setenv.sh exists
if [ ! -f "$SETENV_FILE" ]; then
    echo "Error: File $SETENV_FILE does not exist."
    exit 1
fi

# Ask for user confirmation before overwriting gitrepos.sh
read -p "This will overwrite $GITREPOS_FILE with new data. Are you sure? (y/N) " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit
fi

# Overwrite gitrepos.sh with a header
echo "#!/bin/bash

#****************************************** # 
# Export paths to git repositories
# Will automatically configure with setup_halla_analysis_environment.sh
# For manual build, user configurable
# SSeeds 3.24.24
#****************************************** # 

# Static
export HPC_REPO=$SCRIPT_DIR
#
" > "$GITREPOS_FILE"

# Function to append path modifications to gitrepos.sh
append_repo_path() {
    local key="$1"
    local path="$2"
    # Modify the path if necessary, for example, appending "/g4sbs" if it's the G4SBS path
    if [[ $key == "G4SBS" ]]; then
        path="$path/../g4sbs"
    elif [[ $key == "SIMC" ]]; then
        path="$path/../simc_gfortran"
    elif [[ $key == "LIBSBSDIG" ]]; then
        path="$path/../libsbsdig"
    elif [[ $key == "SBSOFFLINE" ]]; then
        path="$path/../SBS-offline"
    elif [[ $key == "SBS_REPLAY" ]]; then
        path="$path/../SBS-replay"
    fi

    echo "export ${key}_REPO=$path" >> "$GITREPOS_FILE"
}

# Read each line from setenv.sh and process it
while IFS='=' read -r key value; do
    key=$(echo "$key" | sed 's/export //g')
    value=$(echo "$value" | sed 's/"//g' | xargs)
    
    case "$key" in
        G4SBS|SIMC|LIBSBSDIG|SBSOFFLINE|SBS_REPLAY)
            append_repo_path "$key" "$value"
            ;;
        *)
            ;;
    esac
done < "$SETENV_FILE"

echo "gitrepos.sh has been updated with paths from setenv.sh."
