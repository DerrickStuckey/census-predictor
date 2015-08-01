## exploratory analysis

source("../utils/census_utils.R")

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

# stepwise linear regression
# library(MASS)
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
source("../utils/crossval_utils.R")
set.seed(11235)
Pop_Model_Data_Shuffled <- shuffle(Pop_Model_Data)

# test simple model cross-val performance
k=10
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
boxplot(rsq_vals_simple)

# test stepwise-selected model
k=10
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
boxplot(rsq_vals_step) 
