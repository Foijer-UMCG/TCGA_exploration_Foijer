here::i_am("scripts/download_TCGA.R")

download_dataset <- function(dataset_name,
                             download_dir,
                             transcriptome = FALSE,
                             CNV = FALSE,
                             protein = FALSE,
                             clinical = FALSE,
                             force = FALSE,
                             verbose = TRUE){

  dir.create(download_dir,
             recursive = TRUE,
             showWarnings = verbose)

  #TODO want to loop over the data modalities using their name,
  # maybe use a dataframe for this?
  modalities <- c(transcriptome,
                  CNV,
                  protein,
                  clinical)

  if (verbose){
    #TODO does glue work properly like this?
    glue::glue("Starting downloads for {dataset_name}")
  }

  # this loop currently doesn't make sense
  for (data_mode in modalities){
    #TODO wrap this in a tryCatch, as it can throw an error
    # if the data is not available
    query <- create_query(dataset_name = dataset_name,
                          modality = data_mode)

    # want to save the query for later use to check integrity
    #TODO finish the path for saving the data
    saveRDS(query,
            file = file.path(download_dir,
                             ))

    if (verbose){
      glue::glue("Downloading modality {data_mode} for dataset {dataset_name}")
    }

    #TODO check whether this download dest is correct
    TCGAbiolinks::GDCdownload(query = query,
                              method = "api",
                              directory = download_dir)
  }
}

#TODO need to automatically determine the data.type argument
# for a completely correct query
create_query <- function(dataset_name,
                         modality){

  query <- TCGAbiolinks::GDCquery(project = dataset_name,
                                  data.category = modality)

  return(query)

}
