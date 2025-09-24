# here::i_am("scripts/run_analysis.R")

# source all the scripts required for the pipeline
source(file.path(here::i_am(),
                 "scripts",
                 "utils",
                 "sourcing.R"
                 ))
sourceDir(path = file.path(here::i_am(),
                           "scripts"))

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

# starts by downloading data (if required)
if (download){
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
GSEA <- Sys.getenv("GSEA")

# then we preprocess the data if required, based on user input
preprocess_data()

# and finally we start making some plots, again based on user input
plot_figures()
