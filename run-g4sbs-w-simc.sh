#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs g4sbs simulation jobs using SIMC generated events.       #
# ---------                                                                 #
# P. Datta <pdbforce@jlab.org> CREATED 04-19-2023                           #
# ---------                                                                 #
# ** Do not tamper with this sticker! Log any updates to the script above.  #
# ------------------------------------------------------------------------- #

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500

echo 'working directory ='
echo $PWD

#SWIF_JOB_WORK_DIR=$PWD # for testing purposes
echo 'swif_job_work_dir='$SWIF_JOB_WORK_DIR

MODULES=/etc/profile.d/modules.sh 

if [[ $(type -t module) != function && -r ${MODULES} ]]; then 
source ${MODULES} 
fi 

if [ -d /apps/modulefiles ]; then 
module use /apps/modulefiles 
fi 

# setup farm environments
source /site/12gev_phys/softenv.sh 2.4
module load gcc/9.2.0 
ldd /work/halla/sbs/pdbforce/G4SBS/install/bin/g4sbs |& grep not

# Setup g4sbs specific environments
export G4SBS=/work/halla/sbs/pdbforce/G4SBS/install
source $G4SBS/bin/g4sbs.sh

# run the g4sbs command
preinit=$1
postscript=$2
nevents=$3
outfilename=$4
outdirpath=$5
simcoutfile=$6

echo '/g4sbs/simcfile '$6 >>$postscript
echo '/g4sbs/filename '$4 >>$postscript
echo '/g4sbs/run '$3 >>$postscript

cat $postscript

g4sbs --pre=$preinit'.mac' --post=$postscript 

# idiot proofing
if [[ ! -d $outdirpath ]]; then
    mkdir $outdirpath
fi
mv $outfilename $outdirpath