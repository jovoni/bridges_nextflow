
library(bridges)

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
  k_jitter_fix = opt$k_jitter_fix
)

# Save model
saveRDS(bridges_fit, file = file.path(opt$sample_id, "bridges_fit.rds"))

# Plot heatmap
hm_plot <- bridges::plot_heatmap(
  cna_data,
  tree = bridges_fit$tree,
  use_raster = FALSE,
  ladderize = TRUE,
  to_plot = alleles_to_use
)
pdf(file.path(opt$sample_id, "heatmap.pdf"), width = 12, height = 8)
print(hm_plot)
dev.off()

# Save BFB detection report
bfb_report_path <- file.path(opt$sample_id, "bfb_detection_report.pdf")
plot_bfb_detection_report(
  bridges_fit = bridges_fit,
  cna_data = cna_data,
  sample_id = opt$sample_id,
  p_cut = opt$p_cut,
  bfb_report_path = bfb_report_path,
  allele_of_interest = default_allele_to_plot
)
