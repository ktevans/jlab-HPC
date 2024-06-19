#!/bin/bash

# SSeeds 3.24.24
# Script to automatically setup Hall A analysis environment to most recent stable build

##################################################################
# Define username and GitHub account name for cloning repositories
# This is the name which designates your work directory (/work/halla/sbs/USERNAME)
USERNAME=""
# This is the name which designates your home directory (/u/home/CUENAME)
CUENAME=""
# This is the name of the default github repository
GITHUB_ACCOUNT_NAME="JeffersonLab"
# Define user's work directory
WORK_DIR=""
##################################################################
#Override git repos. Leave $GITHUB_ACCOUNT_NAME if default (JeffersonLab) is desired
#Update with alternative forks if desired
G4SBS_REPO_BASE=$GITHUB_ACCOUNT_NAME
LIBSBSDIG_REPO_BASE=$GITHUB_ACCOUNT_NAME
SBS_OFFLINE_REPO_BASE=$GITHUB_ACCOUNT_NAME
SBS_REPLAY_REPO_BASE=$GITHUB_ACCOUNT_NAME
##################################################################

# Define the path to your configuration file
CONFIG_FILE="$WORK_DIR/jlab-HPC/misc/version_control/last_update.conf"

# Load the Git hashes from the configuration file
source $CONFIG_FILE

# Disable strict host key checks for this script's duration
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"

# Load necessary modules
source /etc/profile.d/modules.sh

module purge
module use /group/halla/modulefiles
module load geant4/$G4VER
module load analyzer/$ANAVER
module load cmake

###################################
# Setup SBS-offline with SBS-replay
echo "Setting up SBS-offline and SBS-replay..."
mkdir -p $WORK_DIR/sbsoffline
cd $WORK_DIR/sbsoffline
git clone git@github.com:$SBS_OFFLINE_REPO_BASE/SBS-offline.git
if [ $? -ne 0 ]; then
    echo "Error cloning SBS-offline repository at $SBS_OFFLINE_REPO_BASE/SBS-offline. Exiting..."
    exit 1
fi
git clone git@github.com:$SBS_REPLAY_REPO_BASE/SBS-replay.git
if [ $? -ne 0 ]; then
    echo "Error cloning SBS-replay repository at $SBS_REPLAY_REPO_BASE/SBS-replay. Exiting..."
    exit 1
fi

# Update to stable version of SBS-replay
cd SBS-replay
git checkout $SBS_REPLAY_HASH
if [ $? -ne 0 ]; then
    echo "Error checking out SBS-replay commit. Exiting..."
    exit 1
fi
cd ..

# Set SBS_REPLAY environment variable. No installation required.
export SBS_REPLAY=$WORK_DIR/sbsoffline/SBS-replay

# Create build and install directories for SBS-offline
mkdir build install

# Update to stable version of SBS-offline
cd SBS-offline
git checkout $SBS_OFFLINE_HASH
if [ $? -ne 0 ]; then
    echo "Error checking out SBS-offline commit. Exiting..."
    exit 1
fi

# Install SBS-offline
cd ../build
cmake -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCXXMAXERRORS=1 ../SBS-offline/

make install
if [ $? -ne 0 ]; then
    echo "Error during SBS-offline make install. Exiting..."
    exit 1
fi

# Source the SBS-offline environment script
source ../install/bin/sbsenv.sh

# Set necessary environment variables
export OUT_DIR=/volatile/halla/sbs/$USERNAME
export DB_DIR=$SBS_REPLAY/DB
export LOG_DIR=/volatile/halla/sbs/$USERNAME/logs
export ANALYZER_CONFIGPATH=$SBS_REPLAY/replay

#############
# Setup G4SBS
echo "Setting up G4SBS..."
cd $WORK_DIR
mkdir g4sbs
cd g4sbs
git clone git@github.com:$G4SBS_REPO_BASE/g4sbs.git
if [ $? -ne 0 ]; then
    echo "Error cloning G4SBS repository at $G4SBS_REPO_BASE/g4sbs. Exiting..."
    exit 1
fi
mkdir build install

# Update to stable version of G4SBS
cd g4sbs
git checkout $G4SBS_HASH
if [ $? -ne 0 ]; then
    echo "Error checking out G4SBS commit. Exiting..."
    exit 1
fi

# Configure and install G4SBS
cd ../build
cmake -DCMAKE_INSTALL_PREFIX=../install -INSTALL_SBS_FIELD_MAPS=ON ../g4sbs
if [ $? -ne 0 ]; then
    echo "Error running cmake for G4SBS. Exiting..."
    exit 1
fi
make install
if [ $? -ne 0 ]; then
    echo "Error during G4SBS make install. Exiting..."
    exit 1
fi

# Manually move this gitinfo file for now
cp ../build/include/gitinfo.hh ../install/include/.

# Source g4sbs setup script
source $WORK_DIR/g4sbs/install/bin/g4sbs.sh

#################
# Setup LIBSBSDIG
echo "Setting up LIBSBSDIG..."
cd $WORK_DIR
mkdir libsbsdig
cd libsbsdig
git clone git@github.com:$LIBSBSDIG_REPO_BASE/libsbsdig.git
if [ $? -ne 0 ]; then
    echo "Error cloning LIBSBSDIG repository at $LIBSBSDIG_REPO_BASE/libsbsdig. Exiting..."
    exit 1
fi
mkdir build install

# Update to stable version of LIBSBSDIG
cd libsbsdig
git checkout $LIBSBSDIG_HASH
if [ $? -ne 0 ]; then
    echo "Error checking out LIBSBSDIG commit. Exiting..."
    exit 1
fi

cd ../build
cmake -DCMAKE_INSTALL_PREFIX=../install ../libsbsdig
if [ $? -ne 0 ]; then
    echo "Error running cmake for LIBSBSDIG. Exiting..."
    exit 1
fi

make install
if [ $? -ne 0 ]; then
    echo "Error during LIBSBSDIG make install. Exiting..."
    exit 1
fi

# Source libsbsdig setup script
source $WORK_DIR/libsbsdig/install/bin/sbsdigenv.sh
if [ $? -ne 0 ]; then
    echo "Error sourcing LIBSBSDIG environment script. Exiting..."
    exit 1
fi

#####################
# Setup simc_gfortran
echo "Setting up simc_gfortran..."
cd $WORK_DIR
git clone https://github.com/MarkKJones/simc_gfortran
if [ $? -ne 0 ]; then
    echo "Error cloning simc_gfortran repository. Exiting..."
    exit 1
fi

cd simc_gfortran
git checkout -b bigbite
if [ $? -ne 0 ]; then
    echo "Error creating branch bigbite for simc_gfortran. Exiting..."
    exit 1
fi

git pull origin bigbite
if [ $? -ne 0 ]; then
    echo "Error pulling from bigbite branch of simc_gfortran. Exiting..."
    exit 1
fi

# Update to stable version of SIMC_GFORTRAN
git checkout $SIMC_GFORTRAN_HASH
if [ $? -ne 0 ]; then
    echo "Error checking out simc_gfortran commit. Exiting..."
    exit 1
fi

# Build simc_gfortran with another module
module purge
module load gcc/9.3.0
setup cernlib/2005
make
if [ $? -ne 0 ]; then
    echo "Error during simc_gfortran make. Exiting..."
    exit 1
fi

# Build the root tree software with the original module setup
module purge
module use /group/halla/modulefiles
module load geant4/$G4VER
module load analyzer/$ANAVER
module load cmake

cd util/root_tree
make
if [ $? -ne 0 ]; then
    echo "Error during make of simc_gfortran's root_tree. Exiting..."
    exit 1
fi

echo
echo "Installation completed. Please review any error messages above."
echo

######################################################
# Check .login and offer to update on new installation
echo "Checking .login file for necessary environment variables."

# Define the path to the .login file
LOGIN_FILE="/u/home/$CUENAME/.login"

# Modules and source lines expected to be in .login
MODULE_LINES=(
    "module use /group/halla/modulefiles"
    "module load geant4/11.1.2"
    "module load analyzer/1.7.8"
    "module load cmake"
)

SOURCE_LINES=(
    "source \$SBS/bin/sbsenv.csh"
    "source \${SIM}/bin/g4sbs.csh"
    "source \${LIBSBSDIG}/bin/sbsdigenv.csh"
)

# Environment variable declarations with new values
declare -A ENV_VARS=(
    [OUT_DIR]="/volatile/halla/sbs/$USERNAME"
    [SBS]="$WORK_DIR/sbsoffline/install"
    [SBS_REPLAY]="$WORK_DIR/sbsoffline/SBS-replay"
    [DB_DIR]='\$SBS_REPLAY/DB'
    [LOG_DIR]="/volatile/halla/sbs/$USERNAME/logs"
    [ANALYZER_CONFIGPATH]='\$SBS_REPLAY/replay'
    [SIM]="$WORK_DIR/g4sbs/install"
    [LIBSBSDIG]="$WORK_DIR/libsbsdig/install"
)

# Function to check, prompt, and update line
prompt_and_update_line() {
    local line="$1"
    # Check if the line is present as an active configuration (not commented out)
    if ! grep -Eq "^${line}$" "$LOGIN_FILE"; then
        # If not found as active, then prompt for addition
        echo "The following line is missing from your .login file: $line"
        read -p "Would you like to add it? (y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$line" >> "$LOGIN_FILE"
            echo "Line added."
        else
            echo "Line not added."
        fi
    fi
}

# Function to prompt and update environment variables
prompt_and_update_env_var() {
    local var_name="$1"
    local value="${ENV_VARS[$var_name]}"
    local current_value
    current_value=$(grep "^setenv $var_name" "$LOGIN_FILE" | cut -d' ' -f3-)

    if [[ -z "$current_value" ]] || [[ "$current_value" != "$value" ]]; then
        echo "$var_name is not set or different in your .login file. Current value: '$current_value', New value: '$value'"
        read -p "Would you like to update/set it? (y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if grep -q "^setenv $var_name" "$LOGIN_FILE"; then
                sed -i "/^setenv $var_name/c\setenv $var_name $value" "$LOGIN_FILE"
            else
                echo "setenv $var_name $value" >> "$LOGIN_FILE"
            fi
            echo "$var_name set/updated."
        else
            echo "$var_name not set/updated."
        fi
    fi
}

# Update modules with prompt
for line in "${MODULE_LINES[@]}"; do
    prompt_and_update_line "$line"
done

# Update environment variables with prompt
for var_name in "${!ENV_VARS[@]}"; do
    prompt_and_update_env_var "$var_name"
done

# Update source commands with prompt
for line in "${SOURCE_LINES[@]}"; do
    prompt_and_update_line "$line"
done

echo
echo "Your ~/.login file has been checked and updated as necessary."
echo

#############################################
# Update gitrepos.sh for later version checks

# Define the path to the gitrepos.sh file
GITREPOS_FILE="$WORK_DIR/jlab-HPC/misc/version_control/gitrepos.sh"

# Check if gitrepos.sh exists
if [ ! -f "$GITREPOS_FILE" ]; then
    echo "gitrepos.sh does not exist. Please ensure the file is in the correct location."
    exit 1
fi

# Function to update a single environment variable
update_var() {
    local var_name="$1"
    local new_path="$2"
    local prompt="$3"
    # Check if the variable is declared and non-empty
    if grep -q "^export $var_name=.*$" "$GITREPOS_FILE"; then
        if [ "$(grep "^export $var_name=.*$" "$GITREPOS_FILE" | cut -d'=' -f2)" ]; then
            # Variable exists and isn't empty; prompt the user
            if [ "$prompt" = true ]; then
                echo "$var_name is currently set. Do you want to update it to the new repository path? ($new_path)"
                read -p "(y/n) " -n 1 -r
                echo    # Move to a new line
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    sed -i "s|^export $var_name=.*$|export $var_name=$new_path|g" "$GITREPOS_FILE"
                    echo "$var_name updated."
                else
                    echo "$var_name not updated."
                fi
            fi
        else
            # Variable exists but is empty; update it without prompting
            sed -i "s|^export $var_name=.*$|export $var_name=$new_path|g" "$GITREPOS_FILE"
        fi
    else
        # Variable doesn't exist; add it
        echo "export $var_name=$new_path" >> "$GITREPOS_FILE"
    fi
}

# Define new repository paths
G4SBS_REPO="$WORK_DIR/g4sbs/g4sbs"
SIMC_REPO="$WORK_DIR/simc_gfortran"
LIBSBSDIG_REPO="$WORK_DIR/libsbsdig/libsbsdig"
SBSOFFLINE_REPO="$WORK_DIR/sbsoffline/SBS-offline"
SBS_REPLAY_REPO="$WORK_DIR/sbsoffline/SBS-replay"

# Update or prompt for updates for each variable
update_var "G4SBS_REPO" "$G4SBS_REPO" true
update_var "SIMC_REPO" "$SIMC_REPO" true
update_var "LIBSBSDIG_REPO" "$LIBSBSDIG_REPO" true
update_var "SBSOFFLINE_REPO" "$SBSOFFLINE_REPO" true
update_var "SBS_REPLAY_REPO" "$SBS_REPLAY_REPO" true

echo
echo "gitrepos.sh processing complete."
echo

##################################################
# Lastly, update setenv with new build information

# Define the paths to your files
SETENV_FILE="$WORK_DIR/jlab-HPC/setenv.sh"

# Check if setenv.sh exists
if [ ! -f "$SETENV_FILE" ]; then
    echo "setenv.sh does not exist. Exiting..."
    exit 1
fi

# Parse CONFIG_FILE for versions and hashes
while IFS='=' read -r key value; do
    if [[ $key == "ANAVER" ]]; then
        ANAVER=$value
    elif [[ $key == "G4VER" ]]; then
        G4VER=$value
    fi
done < "$CONFIG_FILE"

# Now proceed with the updates in setenv.sh using the parsed values
# Note: The ANAVER variable update and others follow

# Comment out specific lines
sed -i '/useJLABENV=1/ s/^/#/' "$SETENV_FILE"
sed -i '/JLABENV=.*$/ s/^/#/' "$SETENV_FILE"
sed -i '/export ANALYZER=/ s/^/#/' "$SETENV_FILE"

# Update ANAVER with the new version
sed -i "s/^ANAVER=.*$/ANAVER='$ANAVER'/" "$SETENV_FILE"

# Define new repository paths from your setup
HPC_INSTALL_PATH="$WORK_DIR/jlab-HPC"
G4SBS_INSTALL_PATH="$WORK_DIR/g4sbs/install"
SIMC_INSTALL_PATH="$WORK_DIR/simc_gfortran"
LIBSBSDIG_INSTALL_PATH="$WORK_DIR/libsbsdig/install"
SBSOFFLINE_INSTALL_PATH="$WORK_DIR/sbsoffline/install"
SBS_REPLAY_INSTALL_PATH="$WORK_DIR/sbsoffline/SBS-replay"

# Update paths in setenv.sh
sed -i "s|export SCRIPT_DIR=.*|export SCRIPT_DIR=\"$HPC_INSTALL_PATH\"|" "$SETENV_FILE"
sed -i "s|export G4SBS=.*|export G4SBS=\"$G4SBS_INSTALL_PATH\"|" "$SETENV_FILE"
sed -i "s|export SIMC=.*|export SIMC=\"$SIMC_INSTALL_PATH\"|" "$SETENV_FILE"
sed -i "s|export LIBSBSDIG=.*|export LIBSBSDIG=\"$LIBSBSDIG_INSTALL_PATH\"|" "$SETENV_FILE"
sed -i "s|export SBSOFFLINE=.*|export SBSOFFLINE=\"$SBSOFFLINE_INSTALL_PATH\"|" "$SETENV_FILE"
sed -i "s|export SBS_REPLAY=.*|export SBS_REPLAY=\"$SBS_REPLAY_INSTALL_PATH\"|" "$SETENV_FILE"

echo
echo "setenv.sh has been updated."
echo
echo "All updates complete. The .login file has been updated. To apply the changes in your current session, please source it using the following command:"
echo "source /u/home/$CUENAME/.login"
echo
echo "Additionally, setenv.sh must be reviewed and SCRIPT_PATH must be updated manually before HPC scripts will function."
echo
echo "Happy coding!"
