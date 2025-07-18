nextflow.enable.dsl=2

import groovy.json.JsonSlurper

// Add parameter to control where final results go
params.results_base_dir = "${launchDir}/results"

def input_json = file("resources/sample_params.json")
def json = new JsonSlurper().parseText(input_json.text)
def params_list = json.samples

workflow {

  Channel
    .fromList(params_list)
    .map { p ->
      tuple(p.sample_id, p.h5ad_path, p.cell_quality, p.k_jitter_fix, p.p_cut, p.output_folder)
    }
    .set { param_ch }

  run_bridges_pipeline(param_ch)
}

process run_bridges_pipeline {
  tag { "${sample_id}" }
  
  // Publish to both the original output folder AND your desired results directory
  publishDir "${params.results_base_dir}", mode: 'copy', pattern: "${sample_id}", saveAs: { "${sample_id}" }

  input:
    tuple val(sample_id), val(h5ad_path), val(cell_quality), val(k_jitter_fix), val(p_cut)

  output:
    path "${sample_id}", emit: results

  script:
    """
    mkdir -p ${sample_id}
    
    run_bridges \\
      --sample_id ${sample_id} \\
      --h5ad_path ${h5ad_path} \\
      --cell_quality ${cell_quality} \\
      --k_jitter_fix ${k_jitter_fix} \\
      --p_cut ${p_cut}
    """
}