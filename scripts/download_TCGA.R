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
                     protein = protein,
                     clinical = clinical)

  # creates the directory for downloading the data if not present
  download_dir <- file.path(data_dir,
                            dataset_name)
  if (dir.exists(download_dir) & !force) {
    msg <- glue::glue("Data already seems to be downloaded - feel free to continue workflow!")
    print(msg)
    return("")
  }else{
    dir.create(download_dir,
               recursive = TRUE,
               showWarnings = verbose)
  }

  if (verbose){
    msg <- glue::glue("Starting downloads for {dataset_name}")
    print(msg)
  }

  for (mod in names(modalities)){
    # early exit if FALSE
    if (isFALSE(modalities[[mod]])){
      next
    # clinical only needs to save the query, as that has all the info
    }else if(mod == "clinical"){
      query <- TCGAbiolinks::GDCquery_clinic(project = dataset_name)
      saveRDS(object = query,
              file = file.path(download_dir,
                               "clinical_query.Rds"))
      next
    }
    query_vars <- modality_map[[mod]]
    query <- create_query(dataset_name = dataset_name,
                          data_category = query_vars$data_category,
                          data_type = query_vars$data_type)

    saveRDS(object = query,
            file = file.path(download_dir,
                             paste0(mod, "_query.Rds")))

    if (verbose){
      msg <- glue::glue("Downloading modality {mod} for dataset {dataset_name}")
      print(msg)
    }

    TCGAbiolinks::GDCdownload(query = query,
                              method = "api",
                              directory = download_dir,
                              # 1 file per chunk for stability, might want to change for speedup
                              files.per.chunk = 1)
    if (verbose){
      msg <- glue::glue("Finished downloading modality {mod} for dataset {dataset_name}")
      print(msg)
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
