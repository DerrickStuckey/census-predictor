## knn predictive model 2

# load data
PracticumDataWithLocs <- read.csv("../prepared_data/PracticumDataWithLocs.csv", stringsAsFactors=FALSE)

#calc race percentages
PracticumDataWithLocs$percblack <- PracticumDataWithLocs$Black / PracticumDataWithLocs$X2010pop * 100
PracticumDataWithLocs$percwhite <- PracticumDataWithLocs$White / PracticumDataWithLocs$X2010pop * 100
PracticumDataWithLocs$percasian <- PracticumDataWithLocs$Asian / PracticumDataWithLocs$X2010pop * 100

# use only non-holdout data
population_by_zip_train <- read.csv("../prepared_data/population_by_zip_train.csv")
nonholdout_data <- PracticumDataWithLocs[PracticumDataWithLocs$zipCode %in% population_by_zip_train$zipCode,]

# throw out data w/ no values for race demographics
nonholdout_data <- nonholdout_data[!is.na(nonholdout_data$percwhite) &
                                     !is.na(nonholdout_data$percblack) &
                                     !is.na(nonholdout_data$percasian),]

# further split into current training, validation data sets
nonhouldout_size <- nrow(nonholdout_data)
training_prop <- 0.8
training_idx <- sample(nonhouldout_size,nonhouldout_size*training_prop)
training_data <- nonholdout_data[training_idx,]
validation_data <- nonholdout_data[-training_idx,]

## function to find R-sq for predictions
rsq_val <- function(preds, actuals) {
  sst <- sum((actuals - mean(actuals))^2)
  sse <- sum((actuals - preds)^2)
  return (1 - sse/sst)
}

## build knn models w/ lat/lon vars only
library(FNN)
#remove NA lat/lons
training_data_withlat <- training_data[!is.na(training_data$latitude),]
validation_data_withlat <- validation_data[!is.na(validation_data$latitude),]

# select only lat/lon vars
ziploc_only_training <- subset(training_data_withlat,select=c(latitude,longitude))
ziploc_only_validation <- subset(validation_data_withlat,select=c(latitude,longitude))

## k=4 seems to be the best choice

# obtain lat/lon knn validation predictions for percent white
knn_white_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                     y=training_data_withlat$percwhite,k=4)
summary(knn_white_loc$pred)
rsq_val(knn_white_loc$pred,validation_data_withlat$percwhite)

# obtain lat/lon knn validation predictions for percent black
knn_black_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                     y=training_data_withlat$percblack,k=4)
summary(knn_black_loc$pred)
rsq_val(knn_black_loc$pred,validation_data_withlat$percblack)

# obtain lat/lon knn validation predictions for percent asian
knn_asian_loc <- knn.reg(train=ziploc_only_training,test=ziploc_only_validation,
                     y=training_data_withlat$percasian,k=4)
summary(knn_asian_loc$pred)
rsq_val(knn_asian_loc$pred,validation_data_withlat$percasian)

## obtain knn predictions using other predictors
# retail_only_training <- subset(training_data, 
#                                select=c(starbucks_count, count_fastfood, whole_foods_count,
#                                         walmart_stores, target_stores, home_depot_count,
#                                         lowes_count, basspro_count, f_markets))
# retail_only_validation <- subset(validation_data, 
#                                select=c(starbucks_count, count_fastfood, whole_foods_count,
#                                         walmart_stores, target_stores, home_depot_count,
#                                         lowes_count, basspro_count, f_markets))
retail_only_training <- subset(training_data, 
                               select=c(starbucks_count, count_fastfood, whole_foods_count,
                                        walmart_stores, target_stores, home_depot_count,
                                        lowes_count, basspro_count, f_markets, CVSstores))

retail_only_validation <- subset(validation_data, 
                               select=c(starbucks_count, count_fastfood, whole_foods_count,
                                        walmart_stores, target_stores, home_depot_count,
                                        lowes_count, basspro_count, f_markets, CVSstores))

## attempt at per-capita retail counts
# retail_percapita_training <- retail_only_training * 1000 / (training_data$IRS_rtrns)
# retail_only_training <- retail_percapita_training
# retail_percapita_validation <- retail_only_validation * 1000 / (validation_data$IRS_rtrns)
# retail_only_validation <- retail_percapita_validation
# set all NA values to 0
# retail_only_training[is.na(retail_only_training)] <- 0
# retail_only_validation[is.na(retail_only_validation)] <- 0
## per-capita results no better

# obtain retail knn validation predictions for percent white
knn_white_retail <- knn.reg(train=retail_only_training,test=retail_only_validation,
                         y=training_data$percwhite,k=4)
summary(knn_white_retail$pred)
rsq_val(knn_white_retail$pred,validation_data$percwhite)

# obtain retail knn validation predictions for percent black
knn_black_retail <- knn.reg(train=retail_only_training,test=retail_only_validation,
                            y=training_data$percblack,k=4)
summary(knn_black_retail$pred)
rsq_val(knn_black_retail$pred,validation_data$percblack)

# obtain retail knn validation predictions for percent asian
knn_asian_retail <- knn.reg(train=retail_only_training,test=retail_only_validation,
                            y=training_data$percasian,k=4)
summary(knn_asian_retail$pred)
rsq_val(knn_asian_retail$pred,validation_data$percasian)

# Aggh: negative R-sq values for each retail data model!

## zillow + lat/lon data knn model

# use only training data w/o NA for zillow data
zillow_nna_training <- training_data[!is.na(training_data$homeprice_201501) &
                                               !is.na(training_data$rent_201501),]
zillow_only_training <- subset(zillow_nna_training, 
                               select=c(homeprice_201501,rent_201501))

# same for validation data
zillow_nna_validation <- validation_data[!is.na(validation_data$homeprice_201501) &
                                                   !is.na(validation_data$rent_201501),]
zillow_only_validation <- subset(zillow_nna_validation, 
                               select=c(homeprice_201501,rent_201501))

# zillow percentage white model
knn_white_zillow <- knn.reg(train=zillow_only_training,test=zillow_only_validation,
                            y=zillow_nna_training$percwhite,k=4)
summary(knn_white_zillow$pred)
rsq_val(knn_white_zillow$pred,zillow_nna_validation$percwhite)

# zillow percentage black model
knn_black_zillow <- knn.reg(train=zillow_only_training,test=zillow_only_validation,
                            y=zillow_nna_training$percblack,k=4)
summary(knn_black_zillow$pred)
rsq_val(knn_black_zillow$pred,zillow_nna_validation$percblack)

# zillow percentage asian model
knn_asian_zillow <- knn.reg(train=zillow_only_training,test=zillow_only_validation,
                            y=zillow_nna_training$percasian,k=4)
summary(knn_asian_zillow$pred)
rsq_val(knn_asian_zillow$pred,zillow_nna_validation$percasian)


