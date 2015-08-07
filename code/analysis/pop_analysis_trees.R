## exploratory analysis of population w/ regression analysis
library(MASS)
library(rpart)
library(randomForest)
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

# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_pop_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_tree_cur <- rpart(pop_2010 ~ .-zipCode-state_code, 
                         method="anova", data=training_cur,
                         control=rpart.control(cp=0.001,maxdepth=7))
  preds_cur <- predict(pop_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$pop_2010)
  rsq_vals_pop_tree[iter] <- rsq_cur
}

mean(rsq_vals_pop_tree)
boxplot(rsq_vals_pop_tree,main="Crossval R-sq Pct Graduate Deg Tree")

# construct tree model w/ full training data
pop_tree_fit <- rpart(pop_2010 ~ .-zipCode-state_code, 
                       method="anova",
                       data=Pop_Model_Data_Shuffled,
                       control=rpart.control(cp=0.001,maxdepth=7))
pop_tree_preds <- predict(pop_tree_fit,newdata=Pop_Model_Data_Shuffled)
pop_tree_rsq <- rsq_val(pop_tree_preds,Pop_Model_Data_Shuffled$pop_2010)
pop_tree_rsq
#save the model
save(pop_tree_fit,file="saved_models/pop_tree.rda")

##
## Random Forest population model
##

# measure cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_pop_rf <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_rf_cur <- randomForest(pop_2010 ~ .-zipCode-state_code, data=training_cur,
                              ntree=200,mtry=20,maxnodes=200)
  preds_cur <- predict(pop_rf_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$pop_2010)
  rsq_vals_pop_rf[iter] <- rsq_cur
}

mean(rsq_vals_pop_rf)
boxplot(rsq_vals_pop_rf,main="Crossval R-sq Population RF")

# construct model w/ same params, using full training data
pop_rf_full <- randomForest(pop_2010 ~ .-zipCode-state_code, data=Pop_Model_Data_Shuffled,
                           ntree=200,mtry=20,maxnodes=200)
# save(pop_rf_full,file="saved_models/pop_rf.rda")

# check results
print(pop_rf_full)

# order by importance
term_importance <- data.frame("var"=row.names(importance(pop_rf_full)),
                              importance(pop_rf_full))
sorted_importance <- term_importance[order(term_importance$IncNodePurity,
                                           decreasing=TRUE),]
sorted_importance[0:5,]
sorted_importance[0:10,]

## importance results:
# > sorted_importance[0:10,]
# var IncNodePurity
# IRS_returns             IRS_returns  2.005089e+12
# SS_recip                   SS_recip  1.067140e+12
# care_centers           care_centers  6.520578e+11
# cvs                             cvs  1.886471e+11
# starbucks                 starbucks  1.681358e+11
# gas_stations           gas_stations  1.102722e+11
# fastfood                   fastfood  1.085229e+11
# homeprice_imputed homeprice_imputed  8.271870e+10
# IRS_returns_avg     IRS_returns_avg  6.615690e+10
# valchange_imputed valchange_imputed  6.058709e+10



##
## combined RF and linear models
##
k=5
iters <- seq(1,k,by=1)
rsq_vals_pop_comb <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_simple_cur <- lm(pop_2010 ~ SS_recip + IRS_returns,data=training_cur)
  pop_rf_cur <- randomForest(pop_2010 ~ .-zipCode-state_code, data=training_cur,
                             ntree=200,mtry=20,maxnodes=200)
  
  #fit combined model
  combined_training_cur <- data.frame("pop_2010"=training_cur$pop_2010,
                                      "rf_preds"=pop_rf_cur$predicted,
                                      "lm_preds"=pop_simple_cur$fitted.values)
  combined_mod_cur <- lm(pop_2010 ~ ., data=combined_training_cur)
  
  #construct df for combined mod validation
  rf_preds_cur <- predict(pop_rf_cur,newdata=validation_cur)
  simple_preds_cur <- predict(pop_simple_cur,newdata=validation_cur)
  combined_validation_cur <- data.frame("pop_2010"=validation_cur$pop_2010,
                                        "rf_preds"=rf_preds_cur,
                                        "lm_preds"=simple_preds_cur)
  print("pop_2010, rf_preds_cur, simple_prds_cur:")
  length(validation_cur$pop_2010)
  length(rf_preds_cur)
  length(simple_preds_cur)
  
  combined_preds_cur <- predict(combined_mod_cur,newdata=combined_validation_cur)
  
  rsq_cur <- rsq_val(combined_preds_cur,validation_cur$pop_2010)
  rsq_vals_pop_comb[iter] <- rsq_cur
}

mean(rsq_vals_pop_comb)
# observed r-sq: 0.9811835


