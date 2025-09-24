# here::i_am("scripts/processing.R")

process_data <- function(gene1,
                         gene2){

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

match_modality()
