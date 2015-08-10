## neural network for total population

setwd(".../GWU/practicum/FinalData")

#setting up 5-fold cross validation 
library(caret)

fitControl <- trainControl(method = "cv",number = 5)

# load data
dataWtLog <- read.csv("PopulationData.csv", stringsAsFactors=FALSE)

# carve out holdout data
Model_Data <- dataWtLog[dataWtLog$partition==1,]
Test_Data <- dataWtLog[dataWtLog$partition==0,]

set.seed(1234)

#normalizing training data
library(RSNNS)
normed <-normalizeData(Model_Data, type='0_1')
training <-data.frame(normed)
colnames(training) <-c("zipCode","threezip","partition","pop_2010","SS_recip","IRS_returns","rent_201501","homeprice","valuechange_5year","com_elecrate","ind_elecrate","res_elecrate","beds","gas_stations","fastfood","towers","care_centers","home_daycare","farmers_markets","walmart","target","cvs","home_depot","lowes","whole_foods","basspro","starbucks","beds_avg","gas_stations_avg","fastfood_avg","towers_avg","care_centers_avg","home_daycare_avg","farmers_markets_avg","walmart_avg","target_avg","cvs_avg","home_depot_avg","lowes_avg","whole_foods_avg","basspro_avg","starbucks_avg","SS_recip_sum","IRS_returns_sum","rent_sum","homeprice_sum","SS_recip_avg","IRS_returns_avg","rent_avg","homeprice_avg","beds_sum","gas_stations_sum","fastfood_sum","towers_sum","care_centers_sum","home_daycare_sum","farmers_markets_sum","walmart_sum","target_sum","cvs_sum","home_depot_sum","lowes_sum","whole_foods_sum","basspro_sum","starbucks_sum","SS_imputed","IRS_imputed","rent_imputed","homeprice_imputed","valchange_imputed","latitude","longitude","avgDependents","avgJointRtrns","avgChldTxCred","avgUnemp","avgFrmRtrns","avgTaxes")

#normalizing testing data
testNorm <- normalizeData(Test_Data, type='0_1')
testing <-data.frame(testNorm)
colnames(testing) <-c("zipCode","threezip","partition","pop_2010","SS_recip","IRS_returns","rent_201501","homeprice","valuechange_5year","com_elecrate","ind_elecrate","res_elecrate","beds","gas_stations","fastfood","towers","care_centers","home_daycare","farmers_markets","walmart","target","cvs","home_depot","lowes","whole_foods","basspro","starbucks","beds_avg","gas_stations_avg","fastfood_avg","towers_avg","care_centers_avg","home_daycare_avg","farmers_markets_avg","walmart_avg","target_avg","cvs_avg","home_depot_avg","lowes_avg","whole_foods_avg","basspro_avg","starbucks_avg","SS_recip_sum","IRS_returns_sum","rent_sum","homeprice_sum","SS_recip_avg","IRS_returns_avg","rent_avg","homeprice_avg","beds_sum","gas_stations_sum","fastfood_sum","towers_sum","care_centers_sum","home_daycare_sum","farmers_markets_sum","walmart_sum","target_sum","cvs_sum","home_depot_sum","lowes_sum","whole_foods_sum","basspro_sum","starbucks_sum","SS_imputed","IRS_imputed","rent_imputed","homeprice_imputed","valchange_imputed","latitude","longitude","avgDependents","avgJointRtrns","avgChldTxCred","avgUnemp","avgFrmRtrns","avgTaxes")

#training neural network
mygrid <- expand.grid(.decay=c(0), .size=c(4,5,6))
set.seed(849)
neuralfull <- train(pop_2010 ~ SS_recip+IRS_returns+rent_201501+homeprice+valuechange_5year+com_elecrate+ind_elecrate+res_elecrate+beds+gas_stations+fastfood+towers+care_centers+home_daycare+farmers_markets+walmart+target+cvs+home_depot+lowes+whole_foods+basspro+starbucks+beds_avg+gas_stations_avg+fastfood_avg+towers_avg+care_centers_avg+home_daycare_avg+farmers_markets_avg+walmart_avg+target_avg+cvs_avg+home_depot_avg+lowes_avg+whole_foods_avg+basspro_avg+starbucks_avg+SS_recip_sum+IRS_returns_sum+rent_sum+homeprice_sum+SS_recip_avg+IRS_returns_avg+rent_avg+homeprice_avg+beds_sum+gas_stations_sum+fastfood_sum+towers_sum+care_centers_sum+home_daycare_sum+farmers_markets_sum+walmart_sum+target_sum+cvs_sum+home_depot_sum+lowes_sum+whole_foods_sum+basspro_sum+starbucks_sum+SS_imputed+IRS_imputed+rent_imputed+homeprice_imputed+valchange_imputed+latitude+longitude+avgDependents+avgJointRtrns+avgChldTxCred+avgUnemp+avgFrmRtrns+avgTaxes, data = training, method = "nnet", 
                    trControl = fitControl, tuneGrid = mygrid, maxit = 10000, linout = 1)


#inspecting performance of different models tried - chooses a 4 node model with a RMSE of 0.01623803  
neuralfull
#viewing final weights
summary(neuralfull)

#testing model on test data
results <-predict(neuralfull, newdata = testing)
results <-data.frame(results)
#denormalizing results and combining predictions with actual data
denorm_results <-denormalizeData(results, getNormParameters(testNorm))
denorm_actual <-denormalizeData(testNorm, getNormParameters(testNorm))
final <-cbind(denorm_results,denorm_actual, testing$zipCode)
final <-final[,c(1,5,2)]
colnames(final) <-c('predicted','actual', 'zipCode')
final <-data.frame(final)
final$error <-final$actual- final$predicted 
head(final)

#computing R squared for neural net - final result is R squared of 0.9846463
sst_norm <- sum(sapply(Test_Data$pop_2010,function(x)(x-mean(Test_Data$pop_2010))^2))
nn_sse <-sum((final$error)^2)
nn_r <- 1 - nn_sse/sst_norm
nn_r

#plotting neural network
library(devtools)
source_url('https://gist.githubusercontent.com/fawda123/7471137/raw/466c1474d0a505ff044412703516c34f1a4684a5/nnet_plot_update.r')
plot.nnet(neuralfull, cex.val=.65)


