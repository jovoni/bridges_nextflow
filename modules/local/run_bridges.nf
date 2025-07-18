
process RUN_BRIDGES {
    tag { "${sample_id}" }
    
    conda 'r-base r-bridges r-ggplot2 r-dplyr'
    
    publishDir "${params.results_base_dir}", mode: 'copy', pattern: "${sample_id}", saveAs: { "${sample_id}" }

    input:
    tuple val(sample_id), path(cna_data_file), val(k_jitter_fix), val(p_cut)

    output:
    path "${sample_id}", emit: results

    script:
    """
    #!/usr/bin/env Rscript
    
    # Create output directory
    dir.create("${sample_id}", recursive = TRUE)
    
    # Load the prepared CNA data
    cna_data <- readRDS("${cna_data_file}")
    
    # Source the BRIDGES analysis script
    source("${projectDir}/bin/run_bridges_analysis.R")
    
    # Run BRIDGES analysis with the prepared data
    run_bridges_analysis(
        cna_data = cna_data,
        sample_id = "${sample_id}",
        k_jitter_fix = ${k_jitter_fix},
        p_cut = ${p_cut},
        output_dir = "${sample_id}"
    )
    """
}
