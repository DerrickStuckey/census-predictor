
## function to find R-sq for predictions
rsq_val <- function(preds, actuals) {
  sst <- sum((actuals - mean(actuals))^2)
  sse <- sum((actuals - preds)^2)
  return (1 - sse/sst)
}

## log-odds transform for percentage variable
transform_pct_log_odds <- function(x) {
  # constrain x to interval [1,99] to avoid returning INF
  x <- min(x,99)
  x <- max(x,1)
  odds_x <- x / (100 - x)
  log_odds_x <- log(odds_x)
  return(log_odds_x)
}

## reverse log-odds transform for percentage variable
untransform_pct_log_odds <- function(log_odds_x) {
  odds_x <- exp(log_odds_x)
  x <- 100*(odds_x) / (1+odds_x)
  return(x)
}

## constrain a number to the interval [0,100]
constrain_percent <- function(x) {
  x <- min(x,100)
  x <- max(0,x)
}

