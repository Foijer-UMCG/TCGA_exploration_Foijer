#TODO update this to allow 1 or 2 gene expressions
plot_results <- function(data,
                         results_dir,
                         gene_1,
                         gene_2,
                         dataset_name){

  plot_name <- file.path(results_dir,
                         paste0(gene_1, "_expression.pdf"))

  plot_gene_distro(data = data,
                   gene = gene_1,
                   plot_name = plot_name,
                   cancer_type = dataset_name)

  plot_name <- file.path(results_dir,
                         paste0(gene_2, "_expression.pdf"))

  plot_gene_distro(data = data,
                   gene = gene_2,
                   plot_name = plot_name,
                   cancer_type = dataset_name)

  plot_name <- file.path(results_dir,
                         paste0(gene_1, "_expression_boxplots.pdf"))

  plot_exp_boxplots(data = data,
                     gene = gene_1,
                     cancer_type = dataset_name,
                     plot_name = plot_name)


  plot_exp_boxplots(data = data,
                     gene = gene_2,
                     cancer_type = dataset_name,
                     plot_name = plot_name)

  plot_name <- file.path(results_dir,
                         paste0(gene_1,
                                "_",
                                gene_2,
                                "_corr_plot.pdf"))

  # need to do some renaming here
  plot_genes(df = data,
             gene1 = gene_1,
             gene2 = gene_2,
             plot_name = plot_name,
             cancer_type = dataset_name)

  plot_name <- file.path(results_dir,
                         paste0(gene_1, "_aneuploidy_corr.pdf"))

  plot_aneu_gene_scatter(data = data,
                         gene = gene_1,
                         aneuploidy = "aneuploidy",
                         plot_name = plot_name,
                         cancer_type = dataset_name)

  plot_name <- file.path(results_dir,
                         paste0(gene_2, "_aneuploidy_corr.pdf"))

  plot_aneu_gene_scatter(data = data,
                         gene = gene_2,
                         aneuploidy = "aneuploidy",
                         plot_name = plot_name,
                         cancer_type = dataset_name)


}
