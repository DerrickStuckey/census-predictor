
## function to find R-sq for predictions
rsq_val <- function(preds, actuals) {
  sst <- sum((actuals - mean(actuals))^2)
  sse <- sum((actuals - preds)^2)
  return (1 - sse/sst)
}