#!/usr/bin/env Rscript

# Source the preparation script
source("/Users/jovoni/GitHub/bridges_nextflow/bin/prepare_bridges_input.R")

# Prepare CNA data from signals results
cna_data <- process_signals(
    signals_results = "/Users/jovoni/Library/CloudStorage/Dropbox/MSK_stuff/dlp_data/RPE1_chr4q_p15_clone35_hscn.csv.gz",
    annotation_metrics_csv = "/Users/jovoni/Library/CloudStorage/Dropbox/MSK_stuff/dlp_dataRPE1_chr4q_p15_clone35_metrics.csv.gz",
    cell_quality = 0.75
)

# Save the prepared data
saveRDS(cna_data, "RPE1_chr4q_p15_clone35_cna_data.rds")
