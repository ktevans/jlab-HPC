**jlab-HPC** repository contains scripts to submit and run various simulation and analysis jobs for SBS experiments to Jefferson Lab's HPC clusters using the [Scientific Workflow Indefatigable Factotum](https://scicomp.jlab.org/docs/swif2) (SWIF2) system. All the jobs can be chosen to run on ifarm as well for the purpose of debugging.

## Contents
1. Design
2. Processes
3. Prerequisites
4. Quick start
5. Useful SWIF2 commands
6. Contact

## 1. Design: 
There are mainly four different kind of scripts present in this repository: 
1. **setenv.sh**: This script sets all the necessary environment variables. Since, environment variables are user specific, a first time user needs to set them properly at the beginning. <span style="color:red">Very important!</span>
2. **Run scripts** (name begins with `run-` keyword): Each of these scripts execute individual processes such as g4sbs simulation, digitization, etc. E.g. `run-g4sbs-simu.sh` executes g4sbs simulation jobs. Users shouldn't have to edit or modify these scripts.
3. **Submit scripts** (name begins with `submit-` keyword): These are essentially wrapper scripts. Every run script has one (or more) corresponding submit script(s). Submit scripts take a few command line arguments and run the corresponding run script(s) accordingly. E.g. `submit-g4sbs-jobs.sh` script executes `run-g4sbs-simu.sh` script, which runs g4sbs simulations, according to the command line arguments (e.g. g4sbs macro name, no. of jobs, etc.) given by the user.
4. **Organization scripts**: These scripts are used to organize a replay and make it more streamlined for the user. They take a few arguments and can tell which type of SBS experiment to use and can run single replays or multi replays. This script will subsequently call the proper submit script (above). Right now this is only implemented for real data replays in the script sbs-replay-main.sh. In the future it may be best to make a similar for the simulated data as well.
5. **Hall A software version control**: See 'misc/version_control/last_update.conf for latest stable build git hashes. Script output will include 'version_info.txt' which details all dependent software versions used for jobs contained in same output directory, including active versions of the analyzer and geant4.

## 2. Processes:
Here is a list of processess that can be executed using the scripts present in this repo:
1. raw data reconstruction (replay): Use `sbs-replay-main.sh` script. This will work for all SBS experiments
2. SIMC simulation: Use `submit-simc-jobs.sh` script.
3. g4sbs simulation: Use `submit-g4sbs-jobs.sh` script.
4. digitization of simulated data (sbsdig): Use `submit-sbsdig-job.sh` script.
5. digitized data reconstruction: Use `submit-digireplay-jobs.sh` script.
6. simulation, digitization, & replay in one go (in order): Use `submit-simu-digi-replay-jobs.sh` script.
7. simulation using SIMC generator, digitization, & replay in one go (in order): Use `submit-simc-g4sbs-digi-replay-jobs.sh` script.
8. default environment setup: Use 'misc/setup_halla_analysis_environment' script.

## 3. Prerequisites:
- Most up-to-date build of the following libraries:
  - [simc_gfortran](https://github.com/MarkKJones/simc_gfortran) - Necessary for SIMC simulation jobs. Build from the `bigbite` branch.
  - [g4sbs](https://github.com/JeffersonLab/g4sbs/tree/master) - Necessary for g4sbs simulation jobs. Build from the `uconn_dev` branch.
  - [libsbsdig](https://github.com/JeffersonLab/libsbsdig) - Necessary for digitization (sbsdig) jobs.
  - [analyzer](https://github.com/JeffersonLab/analyzer) - Necessary for replay jobs.
  - [SBS-offline](https://github.com/JeffersonLab/SBS-offline) - Necessary for replay jobs.
  - [SBS-replay](https://github.com/JeffersonLab/SBS-replay) - Necessary for replay jobs.
- `python3` 
 
## 4. Quick start:
1. Modify `setenv.sh` appropriately.
2. Identify the `submit-` script relevant for the process you want to carry out. See section 2 ("Processes") for help.
3. Open the script using an editor and carefully  go through the instructions written at the top.
4. On the terminal, type the name of the script and hit return.
5. List of required arguments should get printed on screen.
6. On the terminal, type the name of the script followed by all the required arguments in order and hit return.

**Example:** Perform the following steps to submit g4sbs simulation, digitization, & reconstruction jobs to batch farm in one go (they will run in order):
1. Open `setenv.sh` script using an editor.
2. Modify the environment variables (SCRIPT_DIR, SIMC, G4SBS, LIBSBSDIG, etc.) appropriately. 
3. On the terminal type `submit-simu-digi-replay-jobs.sh` and hit return to see the list of required arguments.
4. Finally execute: <br>
`submit-simu-digi-replay-jobs.sh example GMN4 100000 0 10 0` <br>
\*\*(Assuming the g4sbs macro, named example.mac, is placed in $G4SBS/scripts directory and we want to run 10 jobs with 100K events per job for GMn SBS4 configuration.)

## 5. Hall A environment setup:
1. Open and modify the preamble at 'misc/setup-halla-analysis-environment.sh'. Ensure that the work directory added is where user desires all parallel builds of G4SBS, libsbsdig, simc_gfortran, sbs-offline, and sbs-replay to be located. By default, the active branches of JeffersonLab (MarkKJones for simc_gfortran) git repositories are set, but forks may be configured in the preamble. Note that user CUENAME and USERNAME may be different. This script does not perform operations to configure ssh or create a functional work directory for the user.
2. Execute the script. All version control files and setenv.sh will be updated automatically.

## 6. Useful SWIF2 commands:
An exhaustive list of all the SWIF2 commands can be found [here](https://scicomp.jlab.org/cli/swif.html). Here is a small list of very useful and common SWIF2 commands:

- `swif2 create <wf_name>` - Creates a SWIF2 workflow with name `wf_name` 
- `swif2 run <wf_name>` - Runs the workflow, `wf_name`
- `swif2 status <wf_name>` - Shows general status of the workflow, `wf_name`
- `swif2 cancel <wf_name> -delete` - Cancels all the jobs in workflow `wf_name` and then deletes it 
- `swif2 retry-jobs <wf_name> -problem <pb_type>` - Reruns all the abandoned jobs in `wf_name` with problem type `pb_type`
- `swif2 modify-jobs <wf_name> -ram mult 2 -problem <pb_type>` - Reruns problem jobs with 2 times more RAM allocation 

## 7. Contact:
In case of any questions or concerns please contact the author(s),
>Authors: Provakar Datta (UConn), Sean Jeffas (UVA), Sebastian Seeds (UConn) <br> 
>Contact: <pdbforce@jlab.org> (Provakar)
