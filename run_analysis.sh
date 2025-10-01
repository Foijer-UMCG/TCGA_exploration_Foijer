#!/bin/bash
# -----------------------------
# run_analysis.sh
# -----------------------------
# Purpose: Run the analysis R script using a specific R version
#          and the project's renv environment, regardless of
#          current working directory.
# -----------------------------

# 1. Load environment variables (your R path, etc.)
source config.env

# 2. Define the project root (adjust this to your actual project folder)
PROJECT_ROOT="/home/alexvkaam/Desktop/data_shared/TCGA_exploration"

# 3. Move to project root
cd "$PROJECT_ROOT" || { echo "Project root not found! Exiting."; exit 1; }

# 4. Path to the R script you want to run
SCRIPT="run_analysis.R"  # change if your script has a different name

# 5. Run the script using the correct R version and activate renv
rig run --script "$SCRIPT" --r-version 4.5.0 2>&1 | tee output.log

#TODO move the output.log to the directory where we save everything!