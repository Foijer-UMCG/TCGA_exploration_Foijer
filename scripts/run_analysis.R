here::i_am("scripts/run_analysis.R")

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
clinical <- Sys.getenv("CLINICAL")
CNV <- Sys.getenv("CNV")
transcriptome <- Sys.getenv("TRANSCRIPTOME")
protein <- Sys.getenv("PROTEIN")
verbose <- Sys.getenv("VERBOSE")
force <- Sys.getenv("FORCE")

# starts by downloading data (if required)
download_dataset(dataset_name = dataset_name,
                 data_dir = data_dir,
                 transcriptome = transcriptome,
                 CNV = CNV,
                 protein = protein,
                 clinical = clinical,
                 force = force,
                 verbose = verbose)

# then we preprocess the data if required, based on user input
preprocess_data()

# and finally we start making some plots, again based on user input
plot_figures()
