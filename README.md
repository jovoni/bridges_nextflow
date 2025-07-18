# BRIDGES Nextflow Pipeline

This pipeline supports BRIDGES analysis from multiple input types using a unified input structure and dedicated workflows for each data type.

## 📦 Supported Input Types

The pipeline can process:

### 1. H5AD Files (AnnData format)
For single-cell data stored in `.h5ad` format:

```bash
nextflow run main.nf --input_json resources/sample_params.json
```

**Required fields in JSON:**
- `sample_id`: Unique sample name
- `input_type`: Must be `"h5ad"`
- `input_path`: Path to `.h5ad` file
- `cell_quality`: Cell quality threshold (0-1)
- `k_jitter_fix`: Jitter smoothing parameter
- `p_cut`: P-value threshold for BFB detection

---

### 2. HMMcopy Results
For bulk or single-cell HMMcopy output:

```bash
nextflow run main.nf --input_json resources/sample_params.json
```

**Required fields in JSON:**
- `sample_id`: Unique sample name
- `input_type`: Must be `"hmmcopy"`
- `input_path`: Path to HMMcopy `reads.csv.gz`
- `annotation_path`: Path to metrics/annotation CSV
- `cell_quality`: Cell quality threshold
- `k_jitter_fix`: Jitter smoothing parameter
- `p_cut`: P-value threshold

---

### 3. Signals Results
For allele-specific CNA signals:

```bash
nextflow run main.nf --input_json resources/sample_params.json
```

**Required fields in JSON:**
- `sample_id`: Unique sample name
- `input_type`: Must be `"signals"`
- `input_path`: Path to signals results CSV
- `annotation_path`: Path to metrics CSV
- `cell_quality`: Cell quality threshold
- `k_jitter_fix`: Jitter smoothing parameter
- `p_cut`: P-value threshold

---

## 📁 Output Structure

All samples produce the same output structure inside the results directory:

```
results/
└── [sample_id]/
    ├── bridges_fit.rds
    ├── heatmap.pdf
    └── bfb_detection_report.pdf
```

You can customize the base output directory with:

```bash
--results_base_dir /your/output/path
```

---

## 🧪 Example Usage

```bash
# Default run (will use resources/sample_params.json)
nextflow run main.nf

# Use custom input file
nextflow run main.nf --input_json my_custom_inputs.json

# Set custom output folder
nextflow run main.nf --results_base_dir /your/results/dir
```

---

## 📦 Requirements

To run this pipeline, you’ll need the following software installed:

### R Dependencies

- R version ≥ 4.1
- `bridges`: the core R package for phylogenetic inference and BFB detection  
  Install with:

  ```r
  install.packages("devtools")  # if not already installed
  devtools::install_github("jovoni/bridges")
  ```

- `anndata`: used to read `.h5ad` input files  
  This package requires a working Python installation via `reticulate`. You can install it in R with:

  ```r
  reticulate::py_install("anndata")
  ```

- Other R dependencies (installed automatically with `bridges`):
  - `ComplexHeatmap`
  - `ggtree`

### Python Dependencies (Optional)

If you're working with `.h5ad` inputs:
- Python ≥ 3.8
- `anndata` Python module (installed via `reticulate` or with pip):

  ```bash
  pip install anndata
  ```

---

## 🔧 Optional Configuration

You can use a `nextflow.config` file to set:
- Execution profiles (local, slurm, docker, etc.)
- Resource requirements (CPUs, memory)
- Container environments for reproducibility (e.g. `singularity` or `conda`)

---

## 🧪 Example JSON

An example JSON input is available at:

```
resources/sample_params.json
```

This file lists all samples and their metadata, allowing you to batch process mixed input types.
