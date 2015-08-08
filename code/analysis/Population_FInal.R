## Best overall model for population analysis

library(MASS)
library(randomForest)
source("../utils/census_utils.R")
source("../utils/crossval_utils.R")

# load predictors
Practicum_Predictors_Normalized <- read.csv("../../prepared_data/Practicum_Predictors_Normalized.csv", stringsAsFactors=FALSE)

# load targets
Practicum_Targets <- read.csv("../../prepared_data/Practicum_Targets.csv", stringsAsFactors=FALSE)

# construct log-transformed variables
Practicum_Targets$log_pop_2010 <- sapply(Practicum_Targets$pop_2010, sm_log_transform)
Practicum_Predictors_Normalized$log_IRS_returns <- log(Practicum_Predictors_Normalized$IRS_returns - 
                                        min(Practicum_Predictors_Normalized$IRS_returns) + 0.01)
Practicum_Predictors_Normalized$log_SS_recip <- log(Practicum_Predictors_Normalized$SS_recip - 
                                     min(Practicum_Predictors_Normalized$SS_recip) + 0.01)

# carve out holdout data
Model_Target_Data <- Practicum_Targets[Practicum_Targets$partition==1,]
Test_Target_Data <- Practicum_Targets[Practicum_Targets$partition==0,]

# construct model dataset for population
Pop_Model_Target_Data <- subset(Model_Target_Data, select=c(zipCode,pop_2010,log_pop_2010))
Pop_Model_Data <- merge(Pop_Model_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                        all.x=TRUE,all.y=FALSE)

# construct test dataset for population
Test_Target_Data <- subset(Test_Target_Data, select=c(zipCode,pop_2010,log_pop_2010))
Test_Data <- merge(Test_Target_Data,Practicum_Predictors_Normalized,by="zipCode",
                   all.x=TRUE,all.y=FALSE)

# lm formula for log_pop selected against training data
stepformula_logpop <- log_pop_2010 ~ SS_recip + com_elecrate + res_elecrate + beds + 
  towers + care_centers + farmers_markets + towers_avg + care_centers_avg + 
  farmers_markets_avg + cvs_avg + lowes_avg + whole_foods_avg + 
  SS_recip_sum + IRS_returns_sum + homeprice_sum + homeprice_avg + 
  gas_stations_sum + care_centers_sum + farmers_markets_sum + 
  lowes_sum + starbucks_sum + SS_imputed + IRS_imputed + rent_imputed + 
  longitude + avgDependents + avgJointRtrns + avgChldTxCred + 
  avgUnemp + avgFrmRtrns + avgTaxes + log_IRS_returns + log_SS_recip

##
## test on holdout data
##

# load pop_rf_full
# load("saved_models/pop_rf_full.rda")

pop_lm_full <- lm(stepformula_logpop,data=Pop_Model_Data)
pop_rf_full <- randomForest(pop_2010 ~ .-log_pop_2010-zipCode-state_code, data=Pop_Model_Data,
                            ntree=200,mtry=20,maxnodes=200)
save(pop_rf_full,file="saved_models/pop_rf_full.rda")

# un-transform lm predictions
lm_preds_training <- sapply(pop_lm_full$fitted.values,sm_log_untransform)

#fit combined model
combined_training_full <- data.frame("pop_2010"=Pop_Model_Data$pop_2010,
                                     "rf_preds"=pop_rf_full$predicted,
                                     "lm_preds"=lm_preds_training)
combined_mod_full <- lm(pop_2010 ~ ., data=combined_training_full)
summary(combined_mod_full)

#construct df for combined mod test
rf_preds_full <- predict(pop_rf_full,newdata=Test_Data)
lm_preds_full <- predict(pop_lm_full,newdata=Test_Data)
# un-transform lm predictions
lm_preds_full <- sapply(lm_preds_full,sm_log_untransform)
combined_validation_full <- data.frame("pop_2010"=Test_Data$pop_2010,
                                       "rf_preds"=rf_preds_full,
                                       "lm_preds"=lm_preds_full)

combined_preds_full <- predict(combined_mod_full,newdata=combined_validation_full)

rsq_full <- rsq_val(combined_preds_full,Test_Data$pop_2010)
print(rsq_full)
# observed rsq: 0.9848629

#combined model weights:
# (Intercept) -41.119169  12.070489  -3.407 0.000659 ***
# rf_preds      0.623465   0.006027 103.447  < 2e-16 ***
# lm_preds      0.382454   0.005831  65.591  < 2e-16 ***

# print predictions
preds_df <- data.frame("predicted_pop"=combined_preds_full,
                       "actual_pop"=Test_Data$pop_2010,
                       "zipCode"=Test_Data$zipCode,
                       "state_code"=Test_Data$state_code)

preds_df$residual <- preds_df$actual_pop - preds_df$predicted_pop

write.csv(preds_df, file="../../results/population_final_predictions.csv",
          row.names=FALSE,quote=FALSE)


