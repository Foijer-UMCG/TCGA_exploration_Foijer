plot_gene_distro <- function(data, gene, plot_name = FALSE, cancer_type) {
  p <- ggpubr::ggdensity(data,
                         x = gene,
                         add = "mean",
                         rug = TRUE,
                         color = "aneu_factor",
                         fill = "aneu_factor",
                         palette = c("#D81B60", "#1E88E5", "#FFC107")
  ) +
    ggplot2::labs(
      title = sprintf("%s expression distribution per aneu classification, %s", gene, cancer_type),
      y = "Density",
      x = sprintf("%s expression (FKPM)", gene)
    ) +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 20),
                   axis.title = ggplot2::element_text(size = 20))
}

plot_exp_boxplots <- function(data, gene, cancer_type, plot_name = FALSE, return = FALSE) {
  comparisons <- list(
    c("low", "middle"),
    c("low", "high"),
    c("middle", "high")
  )
  p <- ggpubr::ggboxplot(data,
                         x = "aneu_factor",
                         y = gene,
                         color = "aneu_factor",
                         palette = c("#D81B60", "#1E88E5", "#FFC107"),
                         add = "jitter",
                         shape = "aneu_factor"
  ) +
    ggpubr::stat_compare_means(
      comparisons = comparisons,
      label = "p.signif"
    ) +
    ggpubr::stat_compare_means(label.x.npc = "left",
                               label.y.npc = "top") +
    ggplot2::theme(text = ggplot2::element_text(size = 20),
                   axis.title = ggplot2::element_text(size = 20))
}

plot_genes <- function(df, gene1, gene2, plot_name = FALSE, cancer_type, return = FALSE) {

  p <- ggpubr::ggscatter(df,
                         x = gene1,
                         y = gene2,
                         color = "#1E88E5",
                         size = 0.7,
                         add = "reg.line",
                         conf.int = TRUE,
                         conf.int.level = 0.95,
                         cor.coef = TRUE,
                         cor.coeff.args = list(method = "pearson"),
                         add.params = list(color = "red"),
                         title = sprintf("%s expression against %s expression, %s", gene1, gene2, cancer_type),
                         xlab = sprintf("%s (FPKM)", gene1),
                         ylab = sprintf("%s (FPKM)", gene2)
  ) +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 20),
                   axis.title = ggplot2::element_text(size = 20))
}

plot_aneu_gene_scatter <- function(data, gene, aneuploidy, plot_name = FALSE, cancer_type, return = FALSE) {
  p <- ggpubr::ggscatter(data,
                         x = aneuploidy,
                         xlab = "Aneuploidy score",
                         y = gene,
                         ylab = sprintf("%s (FPKM)", gene),
                         title = sprintf(
                           "Aneuploidy against %s expression, %s",
                           gene, cancer_type
                         ),
                         color = "#1E88E5",
                         size = 0.7,
                         add = "reg.line",
                         conf.int = TRUE,
                         conf.int.level = 0.95,
                         cor.coef = T,
                         cor.coeff.args = list(method = "pearson"),
                         add.params = list(color = "red")
  ) +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 20),
                   axis.title = ggplot2::element_text(size = 20))
}
