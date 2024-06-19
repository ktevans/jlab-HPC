#!/bin/bash

## -----------
## This script submits simc deep & deen jobs simultaneously.
## NOTE:
## 1. SIMC & g4sbs input file names will have to be the same
##    expect for deep/deen part.
## 2. outdirpath will have to be the same.
## 3. workflowname will have to be the same.
## --------
## P. Datta <pdbforce@jlab.org> CREATED 06/16/23

export SCRIPT_DIR=

# arguments
infilebase=$1   # SIMC input file name w/o "_deep/_deen.inp" part 
sbsconfig=$2    # SBS configuration (Valid options: GMN4,GMN7,GMN11,GMN14,GMN8,GMN9)
nevents=$3      # No. of SIMC (and g4sbs) events to generate
fjobid=$4       # first job id
njobs=$5        # total no. of jobs to submit 
run_on_ifarm=$6 # 1=>Yes (If true, runs all jobs on ifarm)

echo -e "Submiting deep jobs.."
yes | $SCRIPT_DIR/submit-simc-g4sbs-digi-replay-jobs.sh $infilebase'_deep' $sbsconfig $nevents $fjobid $njobs $run_on_ifarm

echo -e "Submiting deen jobs.."
yes | $SCRIPT_DIR/submit-simc-g4sbs-digi-replay-jobs.sh $infilebase'_deen' $sbsconfig $nevents $fjobid $njobs $run_on_ifarm

#misc/submit-deep-n-deen-simult-same-outdir.sh 0p815sf_sbs7_sbs85p_simc GMN7 100 100 0
