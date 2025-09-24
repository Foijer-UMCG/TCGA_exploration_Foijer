load_transcriptome <- function(filepath){
  RNAseq_data <- read.csv(file = filepath,
                          sep = "\t",
                          header = TRUE,
                          comment.char = "#")
  return(RNAseq_data)
}

load_CNV <- function(filepath){
  CNV_data <- read.csv(file = filepath,
                       sep = "\t")
  return(CNV_data)
}

