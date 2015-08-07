## predictive models of percent asian per zip code
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
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_asian),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_asian))
Model_Data <- merge(Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                    all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Model_Data_Shuffled <- shuffle(Model_Data)

##
## Fit stepwise regression for percent asian
##

asianlmfit <- lm(perc_asian ~ .-zipCode-state_code, data=Model_Data)
asianstep <- stepAIC(asianlmfit, direction="both")
summary(asianstep)
stepformula_asian <- formula(terms(asianstep))
stepformula_asian

# and test the model's performance w/ cross-validation
k=5
iters <- seq(1,k,by=1)
rsq_vals_asian_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  fit_cur <- lm(stepformula_asian, data=training_cur)
  preds_cur <- predict(fit_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_asian)
  rsq_vals_asian_step[iter] <- rsq_cur
}

mean(rsq_vals_asian_step)
boxplot(rsq_vals_asian_step,main="Crossval R-sq Pct Asian Stepwise")

##
## Fit decision tree for percent asian
##

# test tree cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_asian_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  asian_tree_cur <- rpart(perc_asian ~ .-zipCode-state_code, 
                          method="anova",
                          data=training_cur,
                          control=rpart.control(cp=0.001,maxdepth=7))
  preds_cur <- predict(asian_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_asian)
  rsq_vals_asian_tree[iter] <- rsq_cur
}

mean(rsq_vals_asian_tree)
boxplot(rsq_vals_asian_tree,main="Crossval R-sq Pct Asian Tree")

# Tree model w/ full training set
# asian_tree_fit <- rpart(perc_asian ~ .-zipCode-state_code, 
#                         method="anova",
#                         data=Model_Data_Shuffled,
#                         control=rpart.control(cp=0.001,maxdepth=7))
# asian_tree_preds <- predict(asian_tree_fit,newdata=Model_Data_Shuffled)
# asian_tree_rsq <- rsq_val(asian_tree_preds,Model_Data_Shuffled$perc_asian)

##
## random forest model for pct asian
##

# Random Forest cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_asian_rf <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Model_Data_Shuffled,k,iter)
  asian_rf_cur <- randomForest(perc_asian ~ .-zipCode-state_code, data=training_cur,
                               ntree=200,mtry=20,maxnodes=300)
  preds_cur <- predict(asian_rf_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_asian)
  rsq_vals_asian_rf[iter] <- rsq_cur
}

mean(rsq_vals_asian_rf)
boxplot(rsq_vals_asian_rf,main="Crossval R-sq Pct Asian RF")
# observed rsq: 0.5694 w/ ntree=200,mtry=20,maxnodes=200
# observed rsq: 0.5780 w/ ntree=200,mtry=20,maxnodes=300


# RF model w/ full training data
asian_forest_fit <- randomForest(perc_asian ~ .-zipCode-state_code, data=Model_Data_Shuffled,
                                 ntree=200,mtry=20,maxnodes=300)
print(asian_forest_fit) # view results 
importance(asian_forest_fit) # importance of each predictor
#save the model
save(asian_forest_fit,file="saved_models/asian_deg_rf.rda")

# order by importance
term_importance <- data.frame("var"=row.names(importance(asian_forest_fit)),
                              importance(asian_forest_fit))
sorted_importance <- term_importance[order(term_importance$IncNodePurity,
                                           decreasing=TRUE),]
sorted_importance[0:10,]


##
## test on holdout data
##

# load asian_forest_fit
load("saved_models/asian_deg_rf.rda")

Test_Target_Data <- subset(Test_Target_Data, select=c(zipCode,perc_asian))
Test_Data <- merge(Test_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                   all.x=TRUE,all.y=FALSE)

test_predictions <- predict(asian_forest_fit, Test_Data)

test_rsq <- rsq_val(test_predictions,Test_Data$perc_asian)
test_rsq
# observed test r-sq: 





