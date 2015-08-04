## exploratory analysis of education demographics w/ regression analysis
library(MASS)
library(rpart)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# TODO add SS/IRS ratio as predictor

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_bachelors) & 
                                         !is.na(Practicum_Targets$perc_graddegree),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Edu_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_graddegree))
Edu_Model_Data <- merge(Edu_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Edu_Model_Data_Shuffled <- shuffle(Edu_Model_Data)

##
## Fit stepwise regression for percent grad-degree
##

# gradlmfit <- lm(perc_graddegree ~ .-zipCode-state_code, data=Edu_Model_Data_Shuffled)
# gradstep <- stepAIC(gradlmfit, direction="both")
# summary(gradstep)
# stepformula_grad <- formula(terms(gradstep))
stepformula_grad <- perc_graddegree ~ SS_recip + IRS_returns + rent_201501 + homeprice + 
  valuechange_5year + com_elecrate + ind_elecrate + res_elecrate + 
  beds + gas_stations + towers + care_centers + farmers_markets + 
  walmart + cvs + home_depot + lowes + whole_foods + starbucks + 
  fastfood_avg + towers_avg + care_centers_avg + home_daycare_avg + 
  farmers_markets_avg + target_avg + cvs_avg + lowes_avg + 
  whole_foods_avg + basspro_avg + SS_recip_sum + IRS_returns_sum + 
  homeprice_sum + SS_recip_avg + IRS_returns_avg + rent_avg + 
  homeprice_avg + beds_sum + gas_stations_sum + towers_sum + 
  home_daycare_sum + farmers_markets_sum + target_sum + cvs_sum + 
  home_depot_sum + starbucks_sum + SS_imputed + IRS_imputed + 
  rent_imputed + homeprice_imputed + latitude + longitude + 
  avgDependents + avgJointRtrns + avgChldTxCred + avgUnemp + 
  avgFrmRtrns + avgTaxes

# and test the model's performance w/ cross-validation
k=5
iters <- seq(1,k,by=1)
rsq_vals_grad_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  fit_cur <- lm(stepformula_grad, data=training_cur)
  preds_cur <- predict(fit_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_graddegree)
  rsq_vals_grad_step[iter] <- rsq_cur
}

mean(rsq_vals_grad_step)
boxplot(rsq_vals_grad_step,main="Crossval R-sq Pct Bachelors Stepwise")

##
## Fit decision tree for percent grad degree
##

# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_grad_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  grad_tree_cur <- rpart(perc_graddegree ~ .-zipCode-state_code, 
                         method="anova", data=training_cur,
                         control=rpart.control(cp=0.001,maxdepth=7))
  preds_cur <- predict(grad_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_graddegree)
  rsq_vals_grad_tree[iter] <- rsq_cur
}

mean(rsq_vals_grad_tree)
boxplot(rsq_vals_grad_tree,main="Crossval R-sq Pct Graduate Deg Tree")

# construct tree model w/ full training data
grad_tree_fit <- rpart(perc_graddegree ~ .-zipCode-state_code, 
                       method="anova",
                       data=Edu_Model_Data_Shuffled,
                       control=rpart.control(cp=0.001,maxdepth=7))
grad_tree_preds <- predict(grad_tree_fit,newdata=Edu_Model_Data_Shuffled)
grad_tree_rsq <- rsq_val(grad_tree_preds,Edu_Model_Data_Shuffled$perc_graddegree)
grad_tree_rsq
#save the model
save(grad_tree_fit,file="saved_models/grad_deg_tree.rda")

##
## random forest model for pct grad degree (using whole training set)
##
# library(randomForest)
# grad_forest_fit <- randomForest(perc_graddegree ~ .-zipCode-state_code, data=Edu_Model_Data_Shuffled)
# print(grad_forest_fit) # view results 
# importance(grad_forest_fit) # importance of each predictor
# #save the model
# save(grad_forest_fit,file="saved_models/grad_deg_rf.rda")

##
## test RF model on 20% validation set
##
# training <- select_training(Edu_Model_Data_Shuffled,5,1)
# validation <- select_validation(Edu_Model_Data_Shuffled,5,1)
# 
# grad_forest_fit <- randomForest(perc_graddegree ~ .-zipCode-state_code, data=training,
#                                 ntree=200,mtry=20,maxnodes=200)
# #calculate validation R-sq
# grad_forest_preds <- predict(grad_forest_fit,newdata=validation)
# grad_forest_rsq <- rsq_val(grad_forest_preds,validation$perc_graddegree)
# grad_forest_rsq

# print(grad_forest_fit) # view results 
# importance(grad_forest_fit) # importance of each predictor

#save the model
# save(grad_forest_fit,file="saved_models/grad_deg_rf.rda")

## 
k=5
iters <- seq(1,k,by=1)
rsq_vals_grad_rf <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  grad_rf_cur <- randomForest(perc_graddegree ~ .-zipCode-state_code, data=training_cur,
                              ntree=200,mtry=20,maxnodes=200)
  preds_cur <- predict(grad_rf_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_graddegree)
  rsq_vals_grad_rf[iter] <- rsq_cur
}

mean(rsq_vals_grad_rf)
boxplot(rsq_vals_grad_rf,main="Crossval R-sq Pct Graduate Deg RF")

## construct and save RF model w/ these settings on full training set
grad_rf_model <- randomForest(perc_graddegree ~ .-zipCode-state_code, data=Edu_Model_Data_Shuffled,
                            ntree=200,mtry=20,maxnodes=200)
save(grad_rf_model,file="saved_models/grad_deg_rf.rda")

##
## test on holdout data
##


