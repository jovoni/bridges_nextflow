
library(anndata)
library(dplyr)
library(data.table)

# Function to read AnnData file
read_adata <- function(h5ad_path) {
  anndata::read_h5ad(h5ad_path)
}

# Filter cells by quality threshold
filter_adata_by_cell_quality <- function(adata, cell_quality) {
  if (!"quality" %in% colnames(adata$obs)) {
    stop("Column 'quality' not found in AnnData object.")
  }
  high_quality_cells <- adata$obs[adata$obs$quality >= cell_quality, , drop = FALSE] %>% rownames()
  adata[high_quality_cells, ]
}

# Prepare CNA dataframe from filtered AnnData object
prepare_cna_df <- function(filtered_adata) {
  extract_bin_info <- function(bin) {
    info <- unlist(strsplit(bin, ":"))
    chr <- info[1]
    start_end <- unlist(strsplit(info[2], "-"))
    start <- as.numeric(start_end[1])
    end <- as.numeric(start_end[2])
    dplyr::tibble(chr = chr, start = start, end = end)
  }

  cell_ids <- rownames(filtered_adata$layers[["state"]])
  cna_data <- lapply(colnames(filtered_adata$layers[["state"]]), function(bin) {
    dplyr::bind_cols(
      extract_bin_info(bin),
      dplyr::tibble(cell_id = cell_ids, CN = filtered_adata$layers[["state"]][, bin])
    )
  }) %>% dplyr::bind_rows()

  return(cna_data)
}

process_h5ad <- function(h5ad_path, cell_quality) {
  adata <- read_adata(h5ad_path)
  filtered_adata <- filter_adata_by_cell_quality(adata, cell_quality = cell_quality)
  cna_data <- prepare_cna_df(filtered_adata)

  # Remove chromosomes with all NA
  is_not_all_na <- cna_data %>%
    dplyr::group_by(chr) %>%
    dplyr::summarise(all_na = all(is.na(CN))) %>%
    dplyr::filter(!all_na) %>%
    dplyr::pull(chr)

  cna_data <- cna_data %>%
    dplyr::filter(chr %in% is_not_all_na)

  # Round total CN
  cna_data <- cna_data %>%
    dplyr::mutate(CN = round(CN)) %>%
    dplyr::mutate(CN = as.integer(CN))

  return(cna_data)
}

process_hmmcopy <- function(hmmcopy_results_csv, annotation_metrics_csv, cell_quality) {
  hmmcopy_results <- data.table::fread(hmmcopy_results_csv)
  annotation_metrics <- data.table::fread(annotation_metrics_csv)

  good_cells <- annotation_metrics %>%
    dplyr::filter(quality >= cell_quality & !is_control) %>%
    dplyr::pull(cell_id)

  cna_data <- hmmcopy_results %>%
    dplyr::filter(cell_id %in% good_cells) %>%
    dplyr::select(cell_id, chr, start, end, state) %>%
    dplyr::rename(CN = state)

  # Remove chromosomes with all NA
  is_not_all_na <- cna_data %>%
    dplyr::group_by(chr) %>%
    dplyr::summarise(all_na = all(is.na(CN))) %>%
    dplyr::filter(!all_na) %>%
    dplyr::pull(chr)

  cna_data <- cna_data %>%
    dplyr::filter(chr %in% is_not_all_na)

  # Round and coerce
  cna_data <- cna_data %>%
    dplyr::mutate(CN = round(CN)) %>%
    dplyr::mutate(CN = as.integer(CN))

  return(cna_data)
}

process_signals <- function(signals_results, annotation_metrics_csv, cell_quality) {
  signals_df <- data.table::fread(signals_results, data.table = FALSE)
  metrics_df <- data.table::fread(annotation_metrics_csv, data.table = FALSE)

  good_cells <- metrics_df %>%
    dplyr::filter(quality >= cell_quality & !is_control) %>%
    dplyr::pull(cell_id)

  # Detect and standardize allele-specific column names
  if ("Min" %in% colnames(signals_df) & "Maj" %in% colnames(signals_df)) {
    signals_df <- signals_df %>%
      dplyr::rename(A = Maj, B = Min)
  } else if (!("A" %in% colnames(signals_df) & "B" %in% colnames(signals_df))) {
    stop("Could not find allele-specific CN columns (A/B or Maj/Min)")
  }

  signals_df <- signals_df %>%
    dplyr::filter(cell_id %in% good_cells) %>%
    dplyr::select(chr, start, end, cell_id, A, B)

  # Remove chromosomes with only NA
  is_not_all_na <- signals_df %>%
    dplyr::group_by(chr) %>%
    dplyr::summarise(all_na = all(is.na(A) & is.na(B))) %>%
    dplyr::filter(!all_na) %>%
    dplyr::pull(chr)

  signals_df <- signals_df %>%
    dplyr::filter(chr %in% is_not_all_na)

  # Round and cast
  signals_df <- signals_df %>%
    dplyr::mutate(
      A = as.integer(round(A)),
      B = as.integer(round(B))
    )

  return(signals_df)
}
