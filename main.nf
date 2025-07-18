
nextflow.enable.dsl=2

import groovy.json.JsonSlurper

// Add parameter to control where final results go
params.results_base_dir = "${launchDir}/results"

// Parameters for different input types
params.input_json = null

// Include the different main workflows
include { H5AD_MAIN } from './workflows/h5ad_main'
include { HMMCOPY_MAIN } from './workflows/hmmcopy_main'
include { SIGNALS_MAIN } from './workflows/signals_main'

workflow {

    def input_file = params.input_json ?: "resources/sample_params.json"
    def input_json = file(input_file)

    if (!input_json.exists()) {
        error "Input JSON file not found: ${input_file}"
    }

    def json = new JsonSlurper().parseText(input_json.text)
    def params_list = json.samples

    // Filter and route samples by input_type
    def h5ad_samples = params_list.findAll { it.input_type == 'h5ad' }
    def hmmcopy_samples = params_list.findAll { it.input_type == 'hmmcopy' }
    def signals_samples = params_list.findAll { it.input_type == 'signals' }

    if (!h5ad_samples.isEmpty()) {
        Channel
            .fromList(h5ad_samples)
            .map { p ->
                tuple(p.sample_id, p.input_path, p.cell_quality, p.k_jitter_fix, p.p_cut)
            }
            .set { h5ad_ch }

        H5AD_MAIN(h5ad_ch)
    }

    if (!hmmcopy_samples.isEmpty()) {
        Channel
            .fromList(hmmcopy_samples)
            .map { p ->
                tuple(p.sample_id, p.input_path, p.annotation_path, p.cell_quality, p.k_jitter_fix, p.p_cut)
            }
            .set { hmmcopy_ch }

        HMMCOPY_MAIN(hmmcopy_ch)
    }

    if (!signals_samples.isEmpty()) {
        Channel
            .fromList(signals_samples)
            .map { p ->
                tuple(p.sample_id, p.input_path, p.annotation_path, p.cell_quality, p.k_jitter_fix, p.p_cut)
            }
            .set { signals_ch }

        SIGNALS_MAIN(signals_ch)
    }
}
