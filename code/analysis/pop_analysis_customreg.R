## Population analysis w/ interaction terms

library(MASS)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for population
Pop_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,pop_2010))
Pop_Model_Data <- merge(Pop_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Pop_Model_Data_Shuffled <- shuffle(Pop_Model_Data)

training <- select_training(Pop_Model_Data_Shuffled,5,1)
validation <- select_validation(Pop_Model_Data_Shuffled,5,1)

# custom linear model
customformula <- pop_2010 ~ IRS_returns + SS_recip + care_centers + 
  IRS_returns*SS_recip + SS_recip*care_centers + care_centers*IRS_returns +
  starbucks + gas_stations + fastfood + IRS_returns_avg

# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_pop_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_tree_cur <- lm(customformula, data=training)
  preds_cur <- predict(pop_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$pop_2010)
  rsq_vals_pop_tree[iter] <- rsq_cur
}

mean(rsq_vals_pop_tree)
# rsq observed : 0.9738575
