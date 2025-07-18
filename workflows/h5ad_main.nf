
/*
 * Main workflow for H5AD (AnnData) input files
 */

include { PREPARE_H5AD } from '../modules/local/prepare_h5ad'
include { RUN_AND_PLOT } from '../modules/local/run_and_plot'

workflow H5AD_MAIN {
    take:
    h5ad_params_ch // channel: [sample_id, h5ad_path, cell_quality, k_jitter_fix, p_cut]

    main:
    // Prepare CNA data from H5AD files
    PREPARE_H5AD(h5ad_params_ch)
    
    // Run BRIDGES analysis and plotting
    RUN_AND_PLOT(PREPARE_H5AD.out.cna_data)

    emit:
    results = RUN_AND_PLOT.out.results
}
