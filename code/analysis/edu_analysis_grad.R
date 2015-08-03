## exploratory analysis of education demographics w/ regression analysis
library(MASS)
library(rpart)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# remove data w/o education values
Practicum_Targets <- Practicum_Targets[!is.na(Practicum_Targets$perc_bachelors) & 
                                         !is.na(Practicum_Targets$perc_graddegree),]

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for education
Edu_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_graddegree,perc_graddegree))
Edu_Model_Data <- merge(Edu_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Edu_Model_Data_Shuffled <- shuffle(Edu_Model_Data)

##
## Fit stepwise regression for percent bachelor's
##

gradlmfit <- lm(perc_graddegree ~ .-zipCode-perc_bachelors, data=Edu_Model_Data)
gradstep <- stepAIC(gradlmfit, direction="both")
summary(gradstep)
stepformula_grad <- formula(terms(gradstep))

# and test the model's performance w/ cross-validation
k=10
iters <- seq(1,k,by=1)
rsq_vals_grad_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  fit_cur <- lm(stepformula_bach, data=training_cur)
  preds_cur <- predict(fit_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_graddegree)
  rsq_vals_grad_step[iter] <- rsq_cur
}

mean(rsq_vals_grad_step)
boxplot(rsq_vals_grad_step,main="Crossval R-sq Pct Bachelors Stepwise")

##
## Fit decision tree for percent grad degree
##
bach_tree_fit <- rpart(perc_graddegree ~ .-zipCode-perc_bachelors, 
                       method="anova",
                       data=Edu_Model_Data_Shuffled,)
bach_tree_preds <- predict(bach_tree_fit,newdata=Edu_Model_Data_Shuffled)
bach_tree_rsq <- rsq_val(bach_tree_preds,Edu_Model_Data_Shuffled$perc_graddegree)

k=10
iters <- seq(1,k,by=1)
rsq_vals_grad_tree <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  bach_tree_cur <- rpart(perc_graddegree ~ .-zipCode-perc_bachelors, 
                         method="anova",
                         data=training_cur)
  preds_cur <- predict(bach_tree_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_graddegree)
  rsq_vals_grad_tree[iter] <- rsq_cur
}

mean(rsq_vals_grad_tree)
boxplot(rsq_vals_grad_tree,main="Crossval R-sq Pct Bachelors Tree")

##
## random forest model for pct grad degree
##
library(randomForest)
grad_forest_fit <- randomForest(perc_graddegree ~ .-zipCode-perc_bachelors, data=Edu_Model_Data_Shuffled)
print(grad_forest_fit) # view results 
importance(grad_forest_fit) # importance of each predictor
#save the model
save(grad_forest_fit,file="saved_models/grad_deg_rf.rda")

##
## test on holdout data
##


