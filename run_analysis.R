rm(list = ls())

print(getwd())

here::i_am("run_analysis.R")

# source a script to easily source everything else
source(file.path(here::here(),
                 "scripts",
                 "utils",
                 "sourcing.R"))

# sourcing the main scripts and smaller utils
sourceDir(path = file.path(here::here(),
                           "scripts"))
sourceDir(path = file.path(here::here(),
                           "scripts",
                           "utils"))

# reads all the config options into "env"
dotenv::load_dot_env(file.path(here::here(),
                               "config.env"))

# parses some of the env options for the download script
dataset_name <- Sys.getenv("DATASET_NAME")
data_dir <- Sys.getenv("DATA_DIR")
clinical <- as.logical(Sys.getenv("CLINICAL"))
CNV <- as.logical(Sys.getenv("CNV"))
transcriptome <- as.logical(Sys.getenv("TRANSCRIPTOME"))
protein <- as.logical(Sys.getenv("PROTEIN"))
verbose <- as.logical(Sys.getenv("VERBOSE"))
force <- as.logical(Sys.getenv("FORCE"))
download <- as.logical(Sys.getenv("DOWNLOAD_DATA"))

if (download){
  #TODO add internal check for download_dataset if the data already exists
  download_dataset(dataset_name = dataset_name,
                   data_dir = data_dir,
                   transcriptome = transcriptome,
                   CNV = CNV,
                   protein = protein,
                   clinical = clinical,
                   force = force,
                   verbose = verbose)
}

# more parsing for the preprocessing steps
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

# prepares for plotting
results_dir <- file.path(data_dir,
                         dataset_name,
                         run_name)
plot_dir <- file.path(results_dir,
                      "plots")

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

# prepares some of the output documentation
raw_data_filename <- file.path(results_dir,
                               "processed_data.csv")
write.csv(data,
          file = raw_data_filename)

file.copy(from = "config.env",
          to = results_dir,
          recursive = FALSE)
