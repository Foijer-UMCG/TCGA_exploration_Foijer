# here::i_am("scripts/download_TCGA.R")

download_dataset <- function(dataset_name,
                             data_dir,
                             transcriptome = FALSE,
                             CNV = FALSE,
                             protein = FALSE,
                             clinical = FALSE,
                             force = FALSE,
                             verbose = TRUE){

  # modality map for query configuration
  modality_map <- list(
    transcriptome = list(
      data_category = "Transcriptome Profiling",
      data_type = "Gene Expression Quantification"
    ),
    CNV = list(
      data_category = "Copy Number Variation",
      data_type = "Copy Number Segment"
    ),
    protein = list(
      data_category = "Proteome Profiling",
      data_type = "Protein Expression Quantification"
    )
  )

  # links the TRUE/FALSE values from the user to keys in
  # in the modality map
  modalities <- list(transcriptome = transcriptome,
                     CNV = CNV,
                     protein = protein)

  # creates the directory for downloading the data if not present
  dir.create(data_dir,
             recursive = TRUE,
             showWarnings = verbose)

  if (verbose){
    glue::glue("Starting downloads for {dataset_name}")
  }

  for (mod in names(modalities)){
    # early exit if FALSE
    if (isFALSE(modalities[[mod]])){
      next
    }
    query_vars <- modality_map[[mod]]
    query <- create_query(dataset_name = dataset_name,
                          data_category = query_vars$data_category,
                          data_type = query_vars$data_type)

    #TODO test whether this pathing is actually correct
    saveRDS(object = query,
            file = file.path(data_dir,
                             dataset_name,
                             mod,
                             "_query.Rds"))

    if (verbose){
      glue::glue("Downloading modality {data_mode} for dataset {dataset_name}")
    }

    TCGAbiolinks::GDCdownload(query = query,
                              method = "api",
                              directory = data_dir,
                              # 1 file per chunk for stability
                              files.per.chunk = 1)
    if (verbose){
      glue::glue("Finished downloading modality {data_mode} for dataset {dataset_name}")
    }
  }
}

create_query <- function(dataset_name,
                         data_category,
                         data_type){

  query <- TCGAbiolinks::GDCquery(project = dataset_name,
                                  data.category = data_category,
                                  data.type = data_type)

  return(query)
}
