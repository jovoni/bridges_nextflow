
process PREPARE_SIGNALS {
    tag { "${sample_id}" }
    
    conda 'r-base r-dplyr r-readr'
    
    input:
    tuple val(sample_id), val(input_path), val(annotation_path), val(cell_quality), val(k_jitter_fix), val(p_cut)

    output:
    tuple val(sample_id), path("${sample_id}_cna_data.rds"), val(k_jitter_fix), val(p_cut), emit: cna_data

    script:
    """
    #!/usr/bin/env Rscript
    
    # Source the preparation script
    source("${projectDir}/bin/prepare_bridges_input.R")
    
    # Prepare CNA data from signals results
    cna_data <- process_signals(
        signals_results = "${input_path}",
        annotation_metrics_csv = "${annotation_path}",
        cell_quality = ${cell_quality}
    )
    
    # Save the prepared data
    saveRDS(cna_data, "${sample_id}_cna_data.rds")
    """
}
