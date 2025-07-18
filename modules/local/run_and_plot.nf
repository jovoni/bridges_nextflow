/*
 * Common subworkflow for running BRIDGES analysis and plotting
 * This subworkflow takes preprocessed CNA data and runs the core BRIDGES analysis
 */

include { RUN_BRIDGES } from './run_bridges'

workflow RUN_AND_PLOT {
    take:
    cna_data_ch // channel: [sample_id, cna_data_file, k_jitter_fix, p_cut]

    main:
    // Run BRIDGES analysis and plotting
    RUN_BRIDGES(cna_data_ch)

    emit:
    results = RUN_BRIDGES.out.results
}