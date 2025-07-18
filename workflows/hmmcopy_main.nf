
/*
 * Main workflow for HMMcopy results input files
 */

include { PREPARE_HMMCOPY } from '../modules/local/prepare_hmmcopy'
include { RUN_AND_PLOT } from '../modules/local/run_and_plot'

workflow HMMCOPY_MAIN {
    take:
    hmmcopy_params_ch // channel: [sample_id, hmmcopy_path, k_jitter_fix, p_cut]

    main:
    // Prepare CNA data from HMMcopy results
    PREPARE_HMMCOPY(hmmcopy_params_ch)
    
    // Run BRIDGES analysis and plotting
    RUN_AND_PLOT(PREPARE_HMMCOPY.out.cna_data)

    emit:
    results = RUN_AND_PLOT.out.results
}
