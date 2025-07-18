
/*
 * Main workflow for Signals results input files
 */

include { PREPARE_SIGNALS } from '../modules/local/prepare_signals'
include { RUN_AND_PLOT } from '../modules/local/run_and_plot'

workflow SIGNALS_MAIN {
    take:
    signals_params_ch // channel: [sample_id, signals_path, k_jitter_fix, p_cut]

    main:
    // Prepare CNA data from signals results
    PREPARE_SIGNALS(signals_params_ch)
    
    // Run BRIDGES analysis and plotting
    RUN_AND_PLOT(PREPARE_SIGNALS.out.cna_data)

    emit:
    results = RUN_AND_PLOT.out.results
}