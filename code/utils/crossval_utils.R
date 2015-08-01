## cross-validation utils

shuffle <- function(df) {
  return(df[sample(1:nrow(df)), ])
}

select_training <- function(df, k, iteration) {
  numrows <- nrow(df)
  val_start_idx <- get_validation_start_idx(numrows, k, iteration)
  val_end_idx <- get_validation_end_idx(numrows, k, iteration)
  return(df[-(val_start_idx:val_end_idx),])
}

select_validation <- function(df, k, iteration) {
  numrows <- nrow(df)
  start_idx <- get_validation_start_idx(numrows, k, iteration)
  end_idx <- get_validation_end_idx(numrows, k, iteration)
  return( df[start_idx:end_idx,])
}

get_chunk_size <- function(numrows, k) {
  return(numrows/k)
}

get_validation_start_idx <- function(numrows, k, iteration) {
  chunk_size <- get_chunk_size(numrows,k)
  val_start_idx_exact <- (iteration-1)*chunk_size
  return( floor(val_start_idx_exact)+1 )
}

get_validation_end_idx <- function(numrows, k, iteration) {
  chunk_size <- get_chunk_size(numrows,k)
  val_end_idx_exact <- iteration*chunk_size
  return( floor(val_end_idx_exact))
}


