## predictive analysis of percent white per zip code
library(MASS)
library(rpart)
library(randomForest)
library(caret)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_white),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_white))
Model_Data <- merge(Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Model_Data_Shuffled <- shuffle(Model_Data)

##
## Fit stepwise regression for percent white
##

# whitelmfit <- lm(perc_white ~ .-zipCode-state_code, data=Model_Data)
# whitestep <- stepAIC(whitelmfit, direction="both")
# summary(whitestep)
# stepformula_white <- formula(terms(whitestep))
stepformula_white <- perc_white ~ IRS_returns + homeprice + valuechange_5year + com_elecrate + 
  ind_elecrate + res_elecrate + gas_stations + fastfood + towers + 
  care_centers + home_daycare + farmers_markets + walmart + 
  target + cvs + home_depot + whole_foods + starbucks + beds_avg + 
  gas_stations_avg + fastfood_avg + towers_avg + care_centers_avg + 
  farmers_markets_avg + target_avg + cvs_avg + lowes_avg + 
  whole_foods_avg + starbucks_avg + SS_recip_sum + IRS_returns_sum + 
  homeprice_sum + SS_recip_avg + rent_avg + beds_sum + fastfood_sum + 
  towers_sum + care_centers_sum + home_daycare_sum + walmart_sum + 
  target_sum + cvs_sum + home_depot_sum + lowes_sum + starbucks_sum + 
  SS_imputed + IRS_imputed + rent_imputed + valchange_imputed + 
  latitude + longitude + avgDependents + avgJointRtrns + avgChldTxCred + 
  avgUnemp + avgTaxes

# and test the model's performance w/ cross-validation
k=5
iters <- seq(1,k,by=1)
rsq_vals_white_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  fit_cur <- lm(stepformula_white, data=training_cur)
  preds_cur <- predict(fit_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_white)
  rsq_vals_white_step[iter] <- rsq_cur
}

mean(rsq_vals_white_step)
boxplot(rsq_vals_white_step,main="Crossval R-sq Pct White Stepwise")

##
## Fit decision tree for percent white
##

# test tree cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_white_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  white_tree_cur <- rpart(perc_white ~ .-zipCode-state_code, 
                         method="anova",
                         data=training_cur,
                         control=rpart.control(cp=0.001,maxdepth=7))
  preds_cur <- predict(white_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_white)
  rsq_vals_white_tree[iter] <- rsq_cur
}

mean(rsq_vals_white_tree)
boxplot(rsq_vals_white_tree,main="Crossval R-sq Pct White Tree")
# observed rsq: 0.6937155

# Tree model w/ full training set
# white_tree_fit <- rpart(perc_white ~ .-zipCode-state_code, 
#                        method="anova",
#                        data=Model_Data_Shuffled,
#                        control=rpart.control(cp=0.001,maxdepth=7))
# white_tree_preds <- predict(white_tree_fit,newdata=Model_Data_Shuffled)
# white_tree_rsq <- rsq_val(white_tree_preds,Model_Data_Shuffled$perc_white)

##
## Neural Net model
##

training <- select_training(Model_Data_Shuffled,5,1)
validation <- select_validation(Model_Data_Shuffled,5,1)

#obtain best parameters
my.grid <- expand.grid(.decay = c(0), .size = c(10))
nnet_fit <- train(perc_white ~ .-zipCode-state_code, data = training,
                  method = "nnet", maxit = 100, tuneGrid = my.grid, trace = F, linout = 1)
summary(nnet_fit)
# get predictions and rsq
nnet_preds <- predict(nnet_fit, newdata=validation)
rsq_nnet <- rsq_val(nnet_preds,validation$perc_white)
rsq_nnet
# observed rsq: 0.5480474 for 50 iters
# observed rsq: 0.5656072 for 100 iters

##
## random forest model for pct white
##

# Random Forest cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_white_rf <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  white_rf_cur <- randomForest(perc_white ~ .-zipCode-state_code, data=training_cur,
                              ntree=200,mtry=20,maxnodes=300)
  preds_cur <- predict(white_rf_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_white)
  rsq_vals_white_rf[iter] <- rsq_cur
}

mean(rsq_vals_white_rf)
boxplot(rsq_vals_white_rf,main="Crossval R-sq Pct White RF")
# observed rsq: 0.7684135

# RF model w/ full training data
white_forest_fit <- randomForest(perc_white ~ .-zipCode-state_code, data=Model_Data_Shuffled,
                                ntree=200,mtry=20,maxnodes=300)
print(white_forest_fit) # view results 
# importance(white_forest_fit) # importance of each predictor
#save the model
save(white_forest_fit,file="saved_models/white_deg_rf.rda")

# order by importance
term_importance <- data.frame("var"=row.names(importance(white_forest_fit)),
                              importance(white_forest_fit))
sorted_importance <- term_importance[order(term_importance$IncNodePurity,
                                           decreasing=TRUE),]
sorted_importance[0:10,]
# avgJointRtrns       avgJointRtrns     3075050.6
# latitude                 latitude      842902.4
# longitude               longitude      515172.3
# avgDependents       avgDependents      505847.4
# care_centers_avg care_centers_avg      480110.7
# IRS_returns_avg   IRS_returns_avg      303380.8
# beds_avg                 beds_avg      274642.9
# towers_avg             towers_avg      207122.7
# gas_stations_avg gas_stations_avg      173572.7
# avgChldTxCred       avgChldTxCred      152781.5

##
## test on holdout data
##

# load white_forest_fit
load("saved_models/white_deg_rf.rda")

Test_Target_Data <- subset(Test_Target_Data, select=c(zipCode,perc_white))
Test_Data <- merge(Test_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                       all.x=TRUE,all.y=FALSE)

test_predictions <- predict(white_forest_fit, Test_Data)

test_rsq <- rsq_val(test_predictions,Test_Data$perc_white)
test_rsq
# observed test r-sq: 0.7670891



