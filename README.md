# BRIDGES Nextflow Pipeline

This pipeline supports multiple input types for BRIDGES analysis, all using a common `run_and_plot` subworkflow.

## Supported Input Types

### 1. H5AD Files (AnnData format)
For single-cell data stored in H5AD format:

```bash
nextflow run main_new.nf --input_type h5ad --input_json resources/sample_params.json
```

**Required parameters in JSON:**
- `sample_id`: Sample identifier
- `h5ad_path`: Path to H5AD file
- `cell_quality`: Cell quality threshold (0-1)
- `k_jitter_fix`: K jitter fix parameter
- `p_cut`: P-value cutoff for BFB detection

### 2. HMMcopy Results
For preprocessed HMMcopy results:

```bash
nextflow run main_new.nf --input_type hmmcopy --input_json resources/sample_params_hmmcopy.json
```

**Required parameters in JSON:**
- `sample_id`: Sample identifier
- `hmmcopy_path`: Path to HMMcopy results CSV file
- `annotation_path`: Path to annotation CSV file
- `cell_quality`: Cell quality threshold (0-1)
- `k_jitter_fix`: K jitter fix parameter
- `p_cut`: P-value cutoff for BFB detection

### 3. Signals Results
For allele-specific signals data:

```bash
nextflow run main_new.nf --input_type signals --input_json resources/sample_params_signals.json
```

**Required parameters in JSON:**
- `sample_id`: Sample identifier
- `signals_path`: Path to signals results CSV file
- `annotation_path`: Path to annotation CSV file
- `cell_quality`: Cell quality threshold (0-1)
- `k_jitter_fix`: K jitter fix parameter
- `p_cut`: P-value cutoff for BFB detection

## Pipeline Architecture

The modular pipeline consists of:

1. **Input-specific preparation modules:**
   - `PREPARE_H5AD`: Processes H5AD files
   - `PREPARE_HMMCOPY`: Processes HMMcopy results
   - `PREPARE_SIGNALS`: Processes signals results

2. **Common analysis subworkflow:**
   - `RUN_AND_PLOT`: Runs BRIDGES analysis and generates plots

3. **Input-specific main workflows:**
   - `H5AD_MAIN`: Complete workflow for H5AD inputs
   - `HMMCOPY_MAIN`: Complete workflow for HMMcopy inputs
   - `SIGNALS_MAIN`: Complete workflow for signals inputs

## Output Structure

All workflows produce the same output structure:
```
results/
└── [sample_id]/
    ├── bridges_fit.rds
    ├── heatmap.pdf
    └── bfb_detection_report.pdf
```

## Configuration

The pipeline uses the same `nextflow.config` as the original pipeline. You can customize:
- Container/conda environments
- Resource allocation
- Output directories

## Example Usage

```bash
# Run with H5AD input (default)
nextflow run main_new.nf

# Run with HMMcopy results
nextflow run main_new.nf --input_type hmmcopy

# Run with custom input file
nextflow run main_new.nf --input_type signals --input_json my_signals_params.json

# Specify custom results directory
nextflow run main_new.nf --results_base_dir /path/to/results
```
