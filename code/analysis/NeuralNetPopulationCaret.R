## attempt at neural network model for 2010 population w/ caret package
library(caret)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# join the two
# Practicum_Data_Full <- merge(Practicum_Targets,Practicum_Predictors_Normalized,by="zipCode")

# construct model dataset for population
Pop_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,pop_2010))
Pop_Model_Data <- merge(Pop_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# construct training/validation datasets from non-holdout data
set.seed(11235)
Pop_Model_Data_Shuffled <- shuffle(Pop_Model_Data)
training <- select_training(Pop_Model_Data_Shuffled,5,1)
validation <- select_validation(Pop_Model_Data_Shuffled,5,1)

# test validation prediction performance for various #'s of iterations
k=5
iters <- seq(1,k,by=1)
iter_vals <- c(10,20,50,100,200)
rsq_vals <- rep(NA,k)
for (iter in iters) {
  iter_val <- iter_vals[iter]
  my.grid <- expand.grid(.decay = c(0.5, 0.1), .size = c(5, 6, 7))
  nnet_fit <- train(pop_2010 ~ SS_recip + IRS_returns, data = training,
                        method = "nnet", maxit = iter_val, tuneGrid = my.grid, trace = F, linout = 1)
  
  # get predictions and rsq
  nnet_preds <- predict(nnet_fit, newdata=validation)
  rsq_nnet <- rsq_val(nnet_preds,validation$pop_2010)
  rsq_nnet
  rsq_vals[iter] <- rsq_nnet
}

# rsq_vals: 0.6624942807 0.8577966273 0.9167171425 0.9352424589 0.9722477569
plot(iters,rsq_vals)
