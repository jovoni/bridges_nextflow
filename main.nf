
nextflow.enable.dsl=2

import groovy.json.JsonSlurper

// Add parameter to control where final results go
params.results_base_dir = "${launchDir}/results"

// Parameters for different input types
params.input_type = 'hmmcopy' // Options: 'h5ad', 'hmmcopy', 'signals'
params.input_json = null

// Include the different main workflows
include { H5AD_MAIN } from './workflows/h5ad_main'
include { HMMCOPY_MAIN } from './workflows/hmmcopy_main'
include { SIGNALS_MAIN } from './workflows/signals_main'

workflow {
    
    // Determine input file
    def input_file = params.input_json ?: "resources/sample_params.json"
    def input_json = file(input_file)
    
    if (!input_json.exists()) {
        error "Input JSON file not found: ${input_file}"
    }
    
    def json = new JsonSlurper().parseText(input_json.text)
    def params_list = json.samples

    // Route to appropriate workflow based on input type
    if (params.input_type == 'h5ad') {
        Channel
            .fromList(params_list)
            .map { p ->
                tuple(p.sample_id, p.h5ad_path, p.cell_quality, p.k_jitter_fix, p.p_cut)
            }
            .set { input_ch }
        
        H5AD_MAIN(input_ch)
        
    } else if (params.input_type == 'hmmcopy') {
        Channel
            .fromList(params_list)
            .map { p ->
                tuple(p.sample_id, p.hmmcopy_path, p.annotation_path, p.cell_quality, p.k_jitter_fix, p.p_cut)
            }
            .set { input_ch }
        
        HMMCOPY_MAIN(input_ch)
        
    } else if (params.input_type == 'signals') {
        Channel
            .fromList(params_list)
            .map { p ->
                tuple(p.sample_id, p.signals_path, p.annotation_path, p.cell_quality, p.k_jitter_fix, p.p_cut)
            }
            .set { input_ch }
        
        SIGNALS_MAIN(input_ch)
        
    } else {
        error "Invalid input_type: ${params.input_type}. Must be one of: h5ad, hmmcopy, signals"
    }
}
