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
Edu_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,perc_bachelors,perc_graddegree))
Edu_Model_Data <- merge(Edu_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# shuffle data
set.seed(11235)
Edu_Model_Data_Shuffled <- shuffle(Edu_Model_Data)

##
## Fit stepwise regression for percent bachelor's
##

# bachlmfit <- lm(perc_bachelors ~ .-zipCode-perc_graddegree, data=Edu_Model_Data)
# bachstep <- stepAIC(bachlmfit, direction="both")
# summary(bachstep)
# stepformula_bach <- formula(terms(bachstep))
stepformula_bach <- perc_bachelors ~ SS_recip + IRS_returns + rent_201501 + homeprice + 
  com_elecrate + res_elecrate + beds + gas_stations + farmers_markets + 
  walmart + target + cvs + home_depot + lowes + whole_foods + 
  starbucks + gas_stations_avg + fastfood_avg + care_centers_avg + 
  home_daycare_avg + farmers_markets_avg + walmart_avg + home_depot_avg + 
  lowes_avg + starbucks_avg + SS_recip_sum + IRS_returns_sum + 
  rent_sum + homeprice_sum + SS_recip_avg + IRS_returns_avg + 
  rent_avg + homeprice_avg + towers_sum + home_daycare_sum + 
  walmart_sum + target_sum + cvs_sum + home_depot_sum + lowes_sum + 
  whole_foods_sum + SS_imputed + IRS_imputed + rent_imputed + 
  valchange_imputed + latitude + longitude

# and test the model's performance w/ cross-validation
k=10
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
bach_tree_fit <- rpart(perc_bachelors ~ .-zipCode-perc_graddegree, 
                       method="anova",
                       data=Edu_Model_Data)

k=10
iters <- seq(1,k,by=1)
rsq_vals_bach_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Edu_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Edu_Model_Data_Shuffled,k,iter)
  bach_tree_fit <- rpart(perc_bachelors ~ .-zipCode-perc_graddegree, 
                         method="anova",
                         data=Edu_Model_Data)
  preds_cur <- predict(bach_tree_fit,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$perc_bachelors)
  rsq_vals_bach_step[iter] <- rsq_cur
}

mean(rsq_vals_bach_step)
boxplot(rsq_vals_bach_step,main="Crossval R-sq Pct Bachelors Tree")

