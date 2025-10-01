#!/bin/bash
# -----------------------------
# run_analysis.sh
# -----------------------------
# Purpose: Run the analysis R script using a specific R version
#          and the project's renv environment, regardless of
#          current working directory.
# -----------------------------

# load environment variables 
source config.env

# runs using specified R version and logs
rig run --script run_analysis.R --r-version 4.5.0 2>&1 | tee output.log

# copies log to run directory
cp output.log $DATA_DIR/$DATASET_NAME/$RUN_NAME