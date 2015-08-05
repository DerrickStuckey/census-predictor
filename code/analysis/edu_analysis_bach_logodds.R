## exploratory analysis of education demographics w/ regression analysis
library(MASS)
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

# transform target variable to log-odds form
Edu_Model_Data_Shuffled$perc_bachelors_logodds <- sapply(Edu_Model_Data_Shuffled$perc_bachelors,
                                                                   transform_pct_log_odds)
summary(Edu_Model_Data_Shuffled$perc_bachelors_logodds)

# try basic linear regression cross-validation performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_bach_log <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  fit_cur <- lm(perc_bachelors_logodds ~ .-perc_bachelors-zipCode-state_code, data=training_cur)
  preds_cur_transformed <- predict(fit_cur,newdata=validation_cur)
  preds_cur <- sapply(preds_cur_transformed,untransform_pct_log_odds)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_bachelors)
  rsq_vals_bach_log[iter] <- rsq_cur
}

mean(rsq_vals_bach_log)

##
## Fit stepwise regression for percent bachelor's (log-odds)
##

bachlmfit <- lm(perc_bachelors_logodds ~ .-perc_bachelors-zipCode-state_code, data=Edu_Model_Data_Shuffled)
bachstep <- stepAIC(bachlmfit, direction="both")
summary(bachstep)
stepformula_bach_logodds <- formula(terms(bachstep))

# and test the model's performance w/ cross-validation
k=5
iters <- seq(1,k,by=1)
rsq_vals_bach_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  fit_cur <- lm(stepformula_bach_logodds, data=training_cur)
  preds_cur_transformed <- predict(fit_cur,newdata=validation_cur)
  preds_cur <- sapply(preds_cur_transformed,untransform_pct_log_odds)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_bachelors)
  rsq_vals_bach_step[iter] <- rsq_cur
}

mean(rsq_vals_bach_step)
boxplot(rsq_vals_bach_step,main="Crossval R-sq Pct Bachelors Stepwise")
# r-sq of 0.4181306 observed
