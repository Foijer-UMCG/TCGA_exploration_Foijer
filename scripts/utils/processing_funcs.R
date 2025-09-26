# required for %>%
library(dplyr)

calc_aneuploidy <- function(seg_means,
                            lengths,
                            rounded = FALSE,
                            base_ploidy = 2) {
  # converts the seg means to copy numbers
  CN <- (2^seg_means) * base_ploidy

  # rounds to discrete if flagged - more true to the biology
  if (rounded) {
    CN <- round(CN)
  }

  # calc aneuploidy per bin and length of a bin as total
  bins_aneu <- CN - base_ploidy
  lengths_rescaled <- lengths / sum(lengths)

  # measures the absolute deviation from base ploidy
  aneuploidy <- abs(bins_aneu) * lengths_rescaled
  aneuploidy <- sum(aneuploidy)
  return(aneuploidy)
}

get_idents <- function(x){
  ident <- strsplit(x, split = "-")[[1]][[3]]
  return(ident)
}

primary_matching_string <- function(dataset_name,
                                    samples){
  # welcome to logic matching hell
  #TODO want to update the strings reporting here, should be really informative
  if (grepl("TARGET-", dataset_name) & samples == "PRIMARY"){
    print("TARGET detected - need some other considerations for data processing.
          Setting flags to ensure proper functioning.")
    grep <- TRUE
    matching_string <- "Primary Blood Derived Cancer"
  }else if (grepl("MP2PRT", dataset_name) & samples == "PRIMARY") {
    print("MP2PRT detected - changing some matching strings.")
    grep <- TRUE
    matching_string <- "^Blood Derived Cancer - Bone Marrow"
  }else if (grepl("MMRF", dataset_name) & samples == "PRIMARY"){
    print("MMRF detected - changing some matching strings.")
    grep <- TRUE
    matching_string <- "^Primary Blood Derived Cancer"
  }else if (samples == "PRIMARY"){
    print("Normal TCGA dataset detected, setting normal flags.")
    grep <- FALSE
    matching_string <- "Primary Tumor"
  }

  result <- list(grep = grep,
       matching_string = matching_string)
  return(result)
}


check_data_presence <- function(dataframe,
                                matching_string,
                                base_path,
                                col_name,
                                grep = FALSE){
  # only selects samples matching the given string, possibly with grep
  if (grep){
    selected_samples <- dataframe[grepl(pattern = matching_string,
                                        dataframe$sample_type), ]
  }else{
    selected_samples <- dataframe[dataframe$sample_type == matching_string, ]
  }

  selected_samples <- selected_samples %>%
    dplyr::group_by(patient) %>%
    dplyr::filter(n() == 1) %>%
    dplyr::ungroup()

  data_locs <- data.frame(
    ID = selected_samples$patient,
    load_path = FALSE
  )

  # now need to apply the function so that we get all the load paths for each ID
  data_paths <- apply(selected_samples, 1, function(row){
    file.path(base_path, row["file_id"], row["file_name"])
  })

  # collate together ID and paths
  data_locs$load_path <- data_paths
  colnames(data_locs) <- c("ID", col_name)

  return(data_locs)
}

get_gene_expression <- function(gene_name = NULL,
                                exp_paths){
  #TODO update this into something more consistent
  # not sure if the current implementation works nice with config
  if(is.null(gene_name)){
    glue::glue("Gene name is NULL, make sure to give a genename")
    return(FALSE)
  }

  # loads the expression data and extracts the gene of interest
  gene_expression <- purrr::map_dbl(exp_paths, function(path) {
    exp_data <- load_transcriptome(path)
    exp_data[exp_data$gene_name == gene_name, ]$fpkm_unstranded
  },
  .progress = paste0(gene_name, "_exp_extraction"))

  return(gene_expression)
}
