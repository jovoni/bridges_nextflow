#!/usr/bin/env Rscript

# Source the preparation script
source("/Users/jovoni/GitHub/bridges_nextflow/bin/prepare_bridges_input.R")

# Prepare CNA data from H5AD file
cna_data <- process_h5ad(
    h5ad_path = "/Users/jovoni/Desktop/HLAMP/processed_files/Reads/SA1162/sample_all_filtered.h5ad",
    cell_quality = 0.75
)

# Save the prepared data
saveRDS(cna_data, "SA1162_cna_data.rds")
