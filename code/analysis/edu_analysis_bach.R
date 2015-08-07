## exploratory analysis of education demographics w/ regression analysis
library(MASS)
library(rpart)
library(randomForest)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_bachelors),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Edu_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_bachelors))
Edu_Model_Data <- merge(Edu_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Edu_Model_Data_Shuffled <- shuffle(Edu_Model_Data)

##
## Fit stepwise regression for percent bachelor's
##

# bachlmfit <- lm(perc_bachelors ~ .-zipCode-state_code, data=Edu_Model_Data)
# bachstep <- stepAIC(bachlmfit, direction="both")
# summary(bachstep)
# stepformula_bach <- formula(terms(bachstep))
stepformula_bach <- perc_bachelors ~ SS_recip + IRS_returns + rent_201501 + homeprice + 
  valuechange_5year + ind_elecrate + res_elecrate + beds + 
  care_centers + home_daycare + farmers_markets + walmart + 
  target + cvs + home_depot + lowes + whole_foods + starbucks + 
  gas_stations_avg + fastfood_avg + towers_avg + care_centers_avg + 
  home_daycare_avg + walmart_avg + cvs_avg + home_depot_avg + 
  SS_recip_sum + IRS_returns_sum + rent_sum + homeprice_sum + 
  SS_recip_avg + IRS_returns_avg + rent_avg + homeprice_avg + 
  towers_sum + care_centers_sum + home_daycare_sum + farmers_markets_sum + 
  walmart_sum + target_sum + cvs_sum + lowes_sum + whole_foods_sum + 
  starbucks_sum + SS_imputed + IRS_imputed + rent_imputed + 
  valchange_imputed + latitude + longitude + avgDependents + 
  avgJointRtrns + avgChldTxCred + avgUnemp + avgFrmRtrns + 
  avgTaxes

# and test the model's performance w/ cross-validation
k=5
iters <- seq(1,k,by=1)
rsq_vals_bach_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  fit_cur <- lm(stepformula_bach, data=training_cur)
  preds_cur <- predict(fit_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_bachelors)
  rsq_vals_bach_step[iter] <- rsq_cur
}

mean(rsq_vals_bach_step)
boxplot(rsq_vals_bach_step,main="Crossval R-sq Pct Bachelors Stepwise")

##
## Fit decision tree for percent bachelor's
##

# test tree cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_bach_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  bach_tree_cur <- rpart(perc_bachelors ~ .-zipCode-state_code, 
                         method="anova",
                         data=training_cur,
                         control=rpart.control(cp=0.001,maxdepth=7))
  preds_cur <- predict(bach_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_bachelors)
  rsq_vals_bach_tree[iter] <- rsq_cur
}

mean(rsq_vals_bach_tree)
boxplot(rsq_vals_bach_tree,main="Crossval R-sq Pct Bachelors Tree")

# Tree model w/ full training set
bach_tree_fit <- rpart(perc_bachelors ~ .-zipCode-state_code, 
                       method="anova",
                       data=Edu_Model_Data_Shuffled,
                       control=rpart.control(cp=0.001,maxdepth=7))
bach_tree_preds <- predict(bach_tree_fit,newdata=Edu_Model_Data_Shuffled)
bach_tree_rsq <- rsq_val(bach_tree_preds,Edu_Model_Data_Shuffled$perc_bachelors)


##
## random forest model for pct bachelors
##

# Random Forest cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_bach_rf <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  bach_rf_cur <- randomForest(perc_bachelors ~ .-zipCode-state_code, data=training_cur,
                              ntree=200,mtry=20,maxnodes=300)
  preds_cur <- predict(bach_rf_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_bachelors)
  rsq_vals_bach_rf[iter] <- rsq_cur
}

mean(rsq_vals_bach_rf)
boxplot(rsq_vals_bach_rf,main="Crossval R-sq Pct Bachelors RF")
# observed rsq: 0.5694 w/ ntree=200,mtry=20,maxnodes=200
# observed rsq: 0.5780 w/ ntree=200,mtry=20,maxnodes=300


# RF model w/ full training data
bach_forest_fit <- randomForest(perc_bachelors ~ .-zipCode-state_code, data=Edu_Model_Data_Shuffled,
                                ntree=200,mtry=20,maxnodes=300)
print(bach_forest_fit) # view results 
importance(bach_forest_fit) # importance of each predictor
#save the model
save(bach_forest_fit,file="saved_models/bach_deg_rf.rda")

# order by importance
term_importance <- data.frame("var"=row.names(importance(bach_forest_fit)),
                              importance(bach_forest_fit))
sorted_importance <- term_importance[order(term_importance$IncNodePurity,
                                           decreasing=TRUE),]
sorted_importance[0:10,]
# avgTaxes           avgTaxes     263113.78
# rent_201501     rent_201501     261755.78
# homeprice         homeprice     190626.21
# starbucks         starbucks      64759.71
# avgChldTxCred avgChldTxCred      46260.63
# avgDependents avgDependents      44137.18
# homeprice_avg homeprice_avg      32654.86
# avgUnemp           avgUnemp      31036.01
# longitude         longitude      30113.18
# rent_avg           rent_avg      29272.97

##
## test on holdout data
##

# load bach_forest_fit
load("saved_models/bach_deg_rf.rda")

Edu_Test_Target_Data <- subset(Test_Target_Data, select=c(zipCode,perc_bachelors))
Edu_Test_Data <- merge(Edu_Test_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                       all.x=TRUE,all.y=FALSE)

test_predictions <- predict(bach_forest_fit, Edu_Test_Data)

test_rsq <- rsq_val(test_predictions,Edu_Test_Data$perc_bachelors)
test_rsq
# observed test r-sq: 0.5767788


