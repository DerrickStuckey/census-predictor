## exploratory analysis of population w/ regression analysis
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

# join the two
# Practicum_Data_Full <- merge(Practicum_Targets,Practicum_Predictors_Normalized,by="zipCode")

# construct model dataset for population
Pop_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,pop_2010))
Pop_Model_Data <- merge(Pop_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

##
## construct stepwise regression model w/ all vars
##
# poplmfit <- lm(pop_2010 ~ .-zipCode, data=Pop_Model_Data)
# popstep <- stepAIC(poplmfit, direction="both")
# summary(popstep)
# stepformula <- formula(terms(popstep))
# commented out b/c formula saved below:

stepformula <- pop_2010 ~ SS_recip + IRS_returns + rent_201501 + homeprice + 
  valuechange_5year + com_elecrate + res_elecrate + beds + 
  gas_stations + fastfood + towers + care_centers + home_daycare + 
  farmers_markets + walmart + cvs + lowes + whole_foods + starbucks + 
  beds_avg + gas_stations_avg + fastfood_avg + care_centers_avg + 
  target_avg + lowes_avg + starbucks_avg + SS_recip_sum + IRS_returns_sum + 
  rent_sum + homeprice_sum + SS_recip_avg + IRS_returns_avg + 
  rent_avg + homeprice_avg + beds_sum + gas_stations_sum + 
  fastfood_sum + towers_sum + care_centers_sum + home_daycare_sum + 
  farmers_markets_sum + walmart_sum + target_sum + cvs_sum + 
  home_depot_sum + lowes_sum + whole_foods_sum + basspro_sum + 
  SS_imputed + IRS_imputed + rent_imputed + valchange_imputed + 
  latitude + longitude

popfitsimple <- lm(pop_2010 ~ SS_recip + IRS_returns, data=Pop_Model_Data)
summary(popfitsimple)

# shuffle data
set.seed(11235)
Pop_Model_Data_Shuffled <- shuffle(Pop_Model_Data)

##
## test simple model cross-val performance
##
k=5
iters <- seq(1,k,by=1)
rsq_vals_simple <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_simple_cur <- lm(pop_2010 ~ SS_recip + IRS_returns, data=training_cur)
  preds_cur <- predict(pop_simple_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$pop_2010)
  rsq_vals_simple[iter] <- rsq_cur
}

mean(rsq_vals_simple)
boxplot(rsq_vals_simple,main="Crossval R-sq, SS + IRS only")

##
## test stepwise-selected model
##
k=5
iters <- seq(1,k,by=1)
rsq_vals_step <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_simple_cur <- lm(stepformula, data=training_cur)
  preds_cur <- predict(pop_simple_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$pop_2010)
  rsq_vals_step[iter] <- rsq_cur
}

mean(rsq_vals_step)
boxplot(rsq_vals_step,main="Crossval R-sq, all vars") 

##
## construct stepwise regression model w/ all non-gov't vars
##
# popfit_nogovt <- lm(pop_2010 ~ .-zipCode -SS_recip -IRS_returns -SS_recip_avg 
#                     - IRS_returns_avg - IRS_returns_sum - SS_recip_sum
#                     - SS_imputed - IRS_imputed,
#                     data=Pop_Model_Data)
# popstep_nogovt <- stepAIC(popfit_nogovt, direction="both")
# summary(popstep_nogovt)
# stepformula_nogovt <- formula(terms(popstep_nogovt))
stepformula_nogovt <- pop_2010 ~ rent_201501 + homeprice + valuechange_5year + com_elecrate + 
  ind_elecrate + res_elecrate + beds + gas_stations + fastfood + 
  towers + care_centers + home_daycare + farmers_markets + 
  walmart + target + cvs + home_depot + lowes + basspro + starbucks + 
  beds_avg + fastfood_avg + towers_avg + care_centers_avg + 
  home_daycare_avg + farmers_markets_avg + walmart_avg + target_avg + 
  home_depot_avg + lowes_avg + whole_foods_avg + basspro_avg + 
  starbucks_avg + homeprice_sum + rent_avg + homeprice_avg + 
  beds_sum + gas_stations_sum + fastfood_sum + towers_sum + 
  care_centers_sum + home_daycare_sum + farmers_markets_sum + 
  walmart_sum + lowes_sum + whole_foods_sum + starbucks_sum + 
  rent_imputed + valchange_imputed + latitude + longitude

# and test the model's performance w/ cross-validation
k=5
iters <- seq(1,k,by=1)
rsq_vals_nogovt <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_simple_cur <- lm(stepformula_nogovt, data=training_cur)
  preds_cur <- predict(pop_simple_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$pop_2010)
  rsq_vals_nogovt[iter] <- rsq_cur
}

mean(rsq_vals_nogovt)
boxplot(rsq_vals_nogovt,main="Crossval R-sq, no SS, IRS")

##
## test log-scaled pop model
##
hist(Pop_Model_Data$pop_2010)
Pop_Model_Data$log_pop_2010 <- log(Pop_Model_Data$pop_2010)
hist(Pop_Model_Data$log_pop_2010)
hist(Pop_Model_Data$IRS_returns)
Pop_Model_Data$log_IRS_returns <- log(Pop_Model_Data$IRS_returns - 
                                        min(Pop_Model_Data$IRS_returns) + 0.01)
hist(Pop_Model_Data$log_IRS_returns)
Pop_Model_Data$log_SS_recip <- log(Pop_Model_Data$SS_recip - 
                                     min(Pop_Model_Data$SS_recip) + 0.01)
hist(Pop_Model_Data$log_SS_recip)

# reshuffle data (w/ same seed)
set.seed(11235)
Pop_Model_Data_Shuffled <- shuffle(Pop_Model_Data)

# test log-model cross-val performance
k=5
iters <- seq(1,k,by=1)
rsq_vals_log <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(Pop_Model_Data_Shuffled,k,iter)
  validation_cur <- select_validation(Pop_Model_Data_Shuffled,k,iter)
  pop_simple_cur <- lm(log_pop_2010 ~ log_SS_recip + log_IRS_returns, data=training_cur)
  preds_cur <- predict(pop_simple_cur,newdata=validation_cur)
  rsq_cur <- rsq_val(preds_cur,validation_cur$log_pop_2010)
  rsq_vals_log[iter] <- rsq_cur
}

mean(rsq_vals_log)
boxplot(rsq_vals_log,main="Crossval R-sq, SS + IRS only")

