## Impute missing Zillow Data

library(FNN)

source("./census_utils.R")
source("../utils/crossval_utils.R")

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

# analyze amount of data w/ rent, w/ homeprice, w/ both, w/ neither
rent_no_price <- PracticumDataWithLocs[!is.na(PracticumDataWithLocs$rent_201501) & is.na(PracticumDataWithLocs$homeprice_201501),]
price_no_rent <- PracticumDataWithLocs[is.na(PracticumDataWithLocs$rent_201501) & !is.na(PracticumDataWithLocs$homeprice_201501),]
no_rent_no_price <- PracticumDataWithLocs[is.na(PracticumDataWithLocs$rent_201501) & is.na(PracticumDataWithLocs$homeprice_201501),]
nrow(rent_no_price)
nrow(price_no_rent)
nrow(no_rent_no_price)

###
### Test rent imputation
###

usable_data <- PracticumDataWithLocs

# throw out data w/ 0 population
usable_data <- usable_data[usable_data$X2010pop > 0,]

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
usable_data <- usable_data[!is.na(usable_data$rent_201501),]

dim(usable_data)

crossval_data <- shuffle(usable_data)
# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_rent <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(crossval_data,k,iter)
  validation_cur <- select_validation(crossval_data,k,iter)
  ziploc_train_cur <- subset(training_cur, select=c(latitude,longitude))
  ziploc_val_cur <- subset(validation_cur, select=c(latitude,longitude))
  knn_rent_loc <- knn.reg(train=ziploc_train_cur,test=ziploc_val_cur,
                          y=training_cur$rent_201501,k=4)
  preds_cur <- knn_rent_loc$pred
  rsq_cur <- rsq_val(preds_cur,validation_cur$rent_201501)
  rsq_vals_rent[iter] <- rsq_cur
}

mean(rsq_vals_rent)
boxplot(rsq_vals_rent)

###
### Test homeprice imputation
###

# use full dataset, including holdout data
usable_data <- PracticumDataWithLocs

# throw out data w/ 0 population
usable_data <- usable_data[usable_data$X2010pop > 0,]

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
usable_data <- usable_data[!is.na(usable_data$homeprice_201501),]

dim(usable_data)

crossval_data <- shuffle(usable_data)
# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_homeprice <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(crossval_data,k,iter)
  validation_cur <- select_validation(crossval_data,k,iter)
  ziploc_train_cur <- subset(training_cur, select=c(latitude,longitude))
  ziploc_val_cur <- subset(validation_cur, select=c(latitude,longitude))
  knn_rent_loc <- knn.reg(train=ziploc_train_cur,test=ziploc_val_cur,
                          y=training_cur$homeprice_201501,k=4)
  preds_cur <- knn_rent_loc$pred
  rsq_cur <- rsq_val(preds_cur,validation_cur$homeprice_201501)
  rsq_vals_homeprice[iter] <- rsq_cur
}

mean(rsq_vals_homeprice)
boxplot(rsq_vals_homeprice)

###
### Test valchange imputation
###

# use full dataset, including holdout data
usable_data <- PracticumDataWithLocs

# throw out data w/ 0 population
usable_data <- usable_data[usable_data$X2010pop > 0,]

# throw out data w/ no lat/lon values
usable_data <- usable_data[!is.na(usable_data$latitude),]

# throw out data w/ no Zillow rent data
usable_data <- usable_data[!is.na(usable_data$valuechange_5year),]

dim(usable_data)

crossval_data <- shuffle(usable_data)
# test params w/ cross-validaton
k=5
iters <- seq(1,k,by=1)
rsq_vals_valchange <- rep(NA,k)
for (iter in iters) {
  training_cur <- select_training(crossval_data,k,iter)
  validation_cur <- select_validation(crossval_data,k,iter)
  ziploc_train_cur <- subset(training_cur, select=c(latitude,longitude))
  ziploc_val_cur <- subset(validation_cur, select=c(latitude,longitude))
  knn_rent_loc <- knn.reg(train=ziploc_train_cur,test=ziploc_val_cur,
                          y=training_cur$valuechange_5year,k=4)
  preds_cur <- knn_rent_loc$pred
  rsq_cur <- rsq_val(preds_cur,validation_cur$valuechange_5year)
  rsq_vals_valchange[iter] <- rsq_cur
}

mean(rsq_vals_valchange)
boxplot(rsq_vals_valchange)


