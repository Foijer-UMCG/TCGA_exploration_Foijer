# here::i_am("scripts/processing.R")

process_data <- function(run_name,
                         gene_1,
                         gene_2,
                         GSEA,
                         transcriptome,
                         CNV,
                         protein,
                         samples,
                         data_dir,
                         dataset_name,
                         verbose){

  # prep the output dir for  dataframes
  results_dir <- file.path(data_dir,
                           dataset_name,
                           run_name)
  raw_data_dir <- file.path(data_dir,
                            dataset_name,
                            dataset_name)

  dir.create(results_dir,
             showWarnings = verbose)

  # start preparing dataframes for the expression and aneuploidy of matched
  # samples for transcriptome and aneuploidy
  clinical_data <- readRDS(file.path(data_dir,
                                     dataset_name,
                                     "clinical_query.Rds"))
  CNV_data <- readRDS(file.path(data_dir,
                                dataset_name,
                                "CNV_query.Rds"))[[1]][[1]]
  RNA_data <- readRDS(file.path(data_dir,
                                dataset_name,
                                "transcriptome_query.Rds"))[[1]][[1]]

  #TODO this needs updating to be able to do all different datasets
  # it will currently not scale at all
  # adds patient ID for easier control
  if ("submitter_id" %in% names(clinical_data)){
    RNA_data$patient <- sapply(RNA_data$cases,
                               FUN = get_idents)
    CNV_data$patient <- sapply(CNV_data$cases,
                               FUN = get_idents)
    clinical_data$patient <- sapply(clinical_data$submitter_id,
                                    FUN = get_idents)
    #TODO add more conditionals here
  }else{
    print("Couldn't find IDs!")
  }

  # determine required strings for only the samples we're interested in
  if (samples == "PRIMARY"){
    #TODO this variable name is HORRIBLE
    #TODO also, splitting the functions like I'm intending right now aint great.
    # need to think of something for all of this, it'll become a mess real quick
    result <- primary_matching_string(dataset_name = dataset_name,
                            samples = samples)
  }else if (samples == "METASTATIC"){
    print("This feature isn't complete yet, tell Alex to hurry up")
  }else if (samples == "ALL"){
    print("This feature isn't complete yet, tell Alex to hurry up")
  }

  # create the dataframe we'll use to track sample locations
  transcriptome_presence <-
    check_data_presence(dataframe = RNA_data,
                        matching_string = result$matching_string,
                        #TODO update this path - already have a var that defines this
                        # in the downloading script.
                        base_path = file.path(raw_data_dir,
                                              "Transcriptome_Profiling",
                                              "Gene_Expression_Quantification"),
                        col_name = "RNA_path",
                        grep = result$grep)
  primary_CNV_presence <-
    check_data_presence(dataframe = CNV_data,
                        matching_string = result$matching_string,
                        #TODO update this path - already have a var that defines this
                        # in the downloading script.
                        base_path = file.path(raw_data_dir,
                                              "Copy_Number_Variation",
                                              "Copy_Number_Segment"),
                        col_name = "primary_CNV_path",
                        grep = result$grep)

  # then we join the data on ID
  data_presence <- Reduce(function(x, y) merge(x, y, by = "ID", all = FALSE),
                          list(transcriptome_presence,
                               primary_CNV_presence)
                          # healthy_CNV_presence)
  )

  # calculates the aneuploidy for each sample
  aneuploidy_scores <- purrr::map_dbl(data_presence$primary_CNV_path, function(path) {
    cnv_data <- load_CNV(path)
    calc_aneuploidy(seg_means = cnv_data$Segment_Mean,
                    lengths = cnv_data$End - cnv_data$Start,
                    base_ploidy = 2,
                    rounded = FALSE)
  })

  # and appends it to the main df
  data_presence$aneuploidy <- aneuploidy_scores

  names <- colnames(data_presence)
  data_presence$gene_1 <- get_gene_expression(gene_name = gene_1,
                                              exp_paths = data_presence$RNA_path)
  colnames(data_presence) <- append(names, gene_1)
  if (gene_2 != "") {
    names <- colnames(data_presence)
    data_presence$gene_2 <- get_gene_expression(gene_name = gene_2,
                                                exp_paths = data_presence$RNA_path)
    colnames(data_presence) <- append(names, gene_2)
  }

  # makes the aneuploidy split for categorising
  # defines the aneu_division
  q <- stats::quantile(data_presence$aneuploidy,
                       probs = c(0.30, 0.70),
                       na.rm = TRUE)

  # and adds as factors in the dataframe
  data_presence$aneu_factor <- as.integer(data_presence$aneuploidy>= q[2]) +
    as.integer(data_presence$aneuploidy>= q[1])
  data_presence$aneu_factor <- factor(data_presence$aneu_factor,
                                      levels = c(0, 1, 2),
                                      labels = c("low", "middle", "high"))


  # we save the dataframe into the run directory
  saveRDS(object = data_presence,
          file = file.path(results_dir,
                           "data_filtered.Rds"))

  # and return the data to the main workflow
  return(data_presence)
}


# Should also move this to a utils file
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

