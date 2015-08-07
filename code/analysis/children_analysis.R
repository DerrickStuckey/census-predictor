## Percent Children analysis

library(MASS)
library(rpart)
library(randomForest)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# TODO add SS/IRS ratio as predictor

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$percchildren),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,percchildren))
Model_Data <- merge(Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Model_Data_Shuffled <- shuffle(Model_Data)

##
## Stepwise Regression
##

childlmfit <- lm(percchildren ~ .-zipCode-state_code, data=Model_Data_Shuffled)
childstep <- stepAIC(childlmfit, direction="both")
summary(childstep)
stepformula_child <- formula(terms(childstep))
stepformula_child <- percchildren ~ SS_recip + IRS_returns + rent_201501 + homeprice + 
  valuechange_5year + res_elecrate + beds + care_centers + 
  home_daycare + lowes + starbucks + beds_avg + gas_stations_avg + 
  fastfood_avg + towers_avg + care_centers_avg + home_daycare_avg + 
  farmers_markets_avg + cvs_avg + home_depot_avg + lowes_avg + 
  SS_recip_sum + IRS_returns_sum + homeprice_sum + IRS_returns_avg + 
  rent_avg + homeprice_avg + care_centers_sum + home_daycare_sum + 
  farmers_markets_sum + target_sum + home_depot_sum + lowes_sum + 
  whole_foods_sum + basspro_sum + starbucks_sum + SS_imputed + 
  IRS_imputed + rent_imputed + homeprice_imputed + latitude + 
  longitude + avgDependents + avgJointRtrns + avgChldTxCred + 
  avgUnemp + avgFrmRtrns + avgTaxes

# test cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_child_lm <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  child_tree_cur <- lm(stepformula_child, data=training_cur)
  preds_cur <- predict(child_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$percchildren)
  rsq_vals_child_lm[iter] <- rsq_cur
}

mean(rsq_vals_child_lm)

##
## Decision Tree
##

# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_child_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  child_tree_cur <- rpart(percchildren ~ .-zipCode-state_code, 
                         method="anova", data=training_cur,
                         control=rpart.control(cp=0.001,maxdepth=7))
  preds_cur <- predict(child_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$percchildren)
  rsq_vals_child_tree[iter] <- rsq_cur
}

mean(rsq_vals_child_tree)
# boxplot(rsq_vals_child_tree,main="Crossval R-sq Pct Children")

# construct tree model w/ full training data
# child_tree_fit <- rpart(percchildren ~ .-zipCode-state_code, 
#                        method="anova",
#                        data=Model_Data_Shuffled,
#                        control=rpart.control(cp=0.001,maxdepth=7))
# child_tree_preds <- predict(child_tree_fit,newdata=Model_Data_Shuffled)
# child_tree_rsq <- rsq_val(child_tree_preds,Model_Data_Shuffled$percchildren)
# child_tree_rsq
#save the model
# save(child_tree_fit,file="saved_models/child_tree.rda")

##
## Random Forest
##

training <- select_training(Model_Data_Shuffled,5,1)
validation <- select_validation(Model_Data_Shuffled,5,1)

child_forest_fit <- randomForest(percchildren ~ .-zipCode-state_code, data=training,
                                ntree=200,mtry=20,maxnodes=300)
#calculate validation R-sq
child_forest_preds <- predict(child_forest_fit,newdata=validation)
child_forest_rsq <- rsq_val(child_forest_preds,validation$percchildren)
child_forest_rsq

print(child_forest_fit) # view results 
importance(child_forest_fit) # importance of each predictor

# save the model
save(child_forest_fit,file="saved_models/child_rf.rda")

# order terms by importance
term_importance <- data.frame("var"=row.names(importance(child_forest_fit)),
                              importance(child_forest_fit))
sorted_importance <- term_importance[order(term_importance$IncNodePurity,
                                           decreasing=TRUE),]
sorted_importance[0:10,]

##
## Test best model on holdout sample
##

# load child_forest_fit
load("saved_models/child_rf.rda")

Test_Target_Data <- subset(Test_Target_Data, select=c(zipCode,percchildren))
Test_Data <- merge(Test_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                       all.x=TRUE,all.y=FALSE)

test_predictions <- predict(child_forest_fit, Test_Data)

test_rsq <- rsq_val(test_predictions,Test_Data$percchildren)
test_rsq
# observed test r-sq: 0.3707321

