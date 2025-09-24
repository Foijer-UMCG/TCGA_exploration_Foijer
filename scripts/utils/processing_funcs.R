calc_aneuploidy <- function(seg_means,
                            lengths,
                            rounded = FALSE,
                            base_ploidy = 2) {
  # converts the seg means to copy numbers
  CN <- (2^seg_means) * 2

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
