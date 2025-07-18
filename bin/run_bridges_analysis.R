
#' Run BRIDGES analysis with prepared CNA data
#' 
#' @param cna_data Prepared CNA data frame
#' @param sample_id Sample identifier
#' @param k_jitter_fix K jitter fix parameter
#' @param p_cut P-value cutoff for BFB detection
#' @param output_dir Output directory for results
run_bridges_analysis <- function(cna_data, sample_id, k_jitter_fix = 0, p_cut = 0.01, output_dir = ".") {

  library(bridges)
  library(ggplot2)
  library(dplyr)
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Auto-detect alleles in the input
  if (all(c("A", "B") %in% colnames(cna_data))) {
    alleles_to_use <- c("A", "B")
    default_allele_to_plot <- "A"
  } else if ("CN" %in% colnames(cna_data)) {
    alleles_to_use <- c("CN")
    default_allele_to_plot <- "CN"
  } else {
    stop("Cannot determine alleles: expected CN or A/B columns.")
  }
  
  # Fit BRIDGES tree
  bridges_fit <- bridges::fit(
    data = cna_data,
    alleles = alleles_to_use,
    k_jitter_fix = k_jitter_fix
  )
  
  # Save model
  saveRDS(bridges_fit, file = file.path(output_dir, "bridges_fit.rds"))
  
  # Plot heatmap
  hm_plot <- bridges::plot_heatmap(
    cna_data,
    tree = bridges_fit$tree,
    use_raster = FALSE,
    ladderize = TRUE,
    to_plot = alleles_to_use
  )
  pdf(file.path(output_dir, "heatmap.pdf"), width = 12, height = 8)
  print(hm_plot)
  dev.off()

  plot_bfb_detection_report <- function(bridges_fit, cna_data, sample_id, p_cut, bfb_report_path, allele_of_interest) {
    bfb_detection <- bridges::detect_bfb(bridges_fit)
    bfb_detection$p.adj <- p.adjust(bfb_detection$p.value, method = "BH")
    bfb_detection$is.signif <- bfb_detection$p.adj <= p_cut

    bfbness_plot <- bfb_detection %>%
      dplyr::mutate(chr = factor(chr, levels = c(1:22, "X", "Y"))) %>%
      ggplot(mapping = aes(x = chr, y = mean, fill = is.signif)) +
      geom_col() +
      theme_bw() +
      labs(x = "Chromosome", y = "BFB-ness")

    significant.chrs <- bfb_detection %>%
      dplyr::filter(is.signif) %>%
      dplyr::pull(chr)

    pdf(bfb_report_path, width = 16, height = 9)
    print(bfbness_plot)
    if (length(significant.chrs) > 0) {
      for (chr in significant.chrs) {
        p <- plot_bfb_signature(res = bridges_fit, chr_of_interest = chr, allele_of_interest = allele_of_interest) +
          ggtitle(sample_id, subtitle = paste0("Chromosome ", chr))
        print(p)
      }
    }
    dev.off()
  }
  
  # Save BFB detection report
  bfb_report_path <- file.path(output_dir, "bfb_detection_report.pdf")
  plot_bfb_detection_report(
    bridges_fit = bridges_fit,
    cna_data = cna_data,
    sample_id = sample_id,
    p_cut = p_cut,
    bfb_report_path = bfb_report_path,
    allele_of_interest = default_allele_to_plot
  )
  
  return(bridges_fit)
}