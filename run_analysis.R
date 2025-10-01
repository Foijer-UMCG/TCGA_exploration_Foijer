#TODO some of the order of operations needs to change to make future debugging 
# easier. Would also allow multiple analyses to run in parallel, as currently
# the terminal used to run this will be occupied and only copy things like
# the config last, meaning it cannot be changed while the run is ongoing.

#TODO
# the path management for the plotting and results dir is a little messed up
# ATM, would like to fix that if I ever get dedicated time for this again.
# me = Alex
rm(list = ls())

here::i_am("run_analysis.R")

# source a script to easily source everything else
source(file.path(here::here(),
                 "scripts",
                 "utils",
                 "sourcing.R"))

# sourcing the main scripts and smaller utils
sourceDir(path = file.path(here::here(),
                           "scripts"),
          trace = FALSE) # doesn't output sourced scripts in logs

sourceDir(path = file.path(here::here(),
                           "scripts",
                           "utils"),
          trace = FALSE)

# reads all the config options into "env"
dotenv::load_dot_env(file.path(here::here(),
                               "config.env"))

print("Loaded the config")

# parses some of the env options for the download script
dataset_name <- Sys.getenv("DATASET_NAME")
data_dir <- Sys.getenv("DATA_DIR")
clinical <- as.logical(Sys.getenv("CLINICAL"))
CNV <- as.logical(Sys.getenv("CNV"))
transcriptome <- as.logical(Sys.getenv("TRANSCRIPTOME"))
protein <- as.logical(Sys.getenv("PROTEIN"))
force <- as.logical(Sys.getenv("FORCE"))
verbose <- as.logical(Sys.getenv("VERBOSE"))
download <- as.logical(Sys.getenv("DOWNLOAD_DATA"))

if (download){
  #TODO add internal check for download_dataset if the data already exist
  msg <- download_dataset(dataset_name = dataset_name,
                          data_dir = data_dir,
                          transcriptome = transcriptome,
                          CNV = CNV,
                          protein = protein,
                          clinical = clinical,
                          force = force,
                          verbose = verbose)
  print(msg)
}

# more parsing for the preprocessing steps
#TODO - add automatic recognition of gene names against gene_names.txt
# for easier error handling
gene_1 <- Sys.getenv("GENE_1")
gene_2 <- Sys.getenv("GENE_2")
GSEA <- as.logical(Sys.getenv("GSEA"))
samples <- Sys.getenv("SAMPLES_SELECTED")
run_name <- Sys.getenv("RUN_NAME")

# preprocess the data, matching RNA to CNV samples
data <- process_data(run_name = run_name,
                     gene_1 = gene_1,
                     gene_2 = gene_2,
                     GSEA = GSEA,
                     transcriptome = transcriptome,
                     CNV = CNV,
                     protein = protein,
                     samples = samples,
                     data_dir = data_dir,
                     dataset_name = dataset_name,
                     verbose = verbose)

#TODO move these further to the top of the file in case a run gets interrupted
# that way it would be easier to debug, as we're missing outputs otherwise
# prepares some of the output documentation
# prepares for outputs
results_dir <- file.path(data_dir,
                         dataset_name,
                         run_name)
file.copy(from = "config.env",
          to = results_dir,
          recursive = FALSE)

plot_dir <- file.path(results_dir,
                      "plots")

raw_data_filename <- file.path(results_dir,
                               "processed_data.csv")
write.csv(data,
          file = raw_data_filename)

if (verbose){
  print("Wrote raw data to output directory")
}

# does the plotting
plotting_message <- plot_results(data = data,
                                 results_dir = plot_dir,
                                 gene_1 = gene_1,
                                 gene_2 = gene_2,
                                 dataset_name = dataset_name,
                                 verbose = verbose)

if (verbose){
  print(plotting_message)
}

print(glue::glue("Done! You can find your plots in:\n{plot_dir}"))
