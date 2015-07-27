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

## lat/lon + zillow model
training_loc_rent_nna <- training_data[!is.na(training_data$latitude) &
                                         !is.na(training_data$rent_201501),]
validation_loc_rent_nna <- validation_data[!is.na(validation_data$latitude) &
                                         !is.na(validation_data$rent_201501),]

#TODO find avg population of zips w/, w/o zillow rent data (are those w/o smaller?)

training_loc_rent_only <- subset(training_loc_rent_nna, select=c(latitude,longitude,
                                                                 rent_201501))
validation_loc_rent_only <- subset(validation_loc_rent_nna, select=c(latitude,longitude,
                                                                 rent_201501))
# rescale rent variable to match the scale of latitude
rentsd <- sd(training_loc_rent_only$rent_201501)
latsd <- sd(training_loc_rent_only$latitude)
lonsd <- sd(training_loc_rent_only$longitude)
training_loc_rent_only$rent_201501 <- training_loc_rent_only$rent_201501 / rentsd * latsd
validation_loc_rent_only$rent_201501 <- validation_loc_rent_only$rent_201501 / rentsd * latsd

# loc/rent percentage white model
knn_white_loc_rent <- knn.reg(train=training_loc_rent_only,test=validation_loc_rent_only,
                            y=training_loc_rent_nna$percwhite,k=4)
summary(knn_white_loc_rent$pred)
rsq_val(knn_white_loc_rent$pred,validation_loc_rent_nna$percwhite)

# loc/rent percentage black model
knn_black_loc_rent <- knn.reg(train=training_loc_rent_only,test=validation_loc_rent_only,
                              y=training_loc_rent_nna$percblack,k=4)
summary(knn_black_loc_rent$pred)
rsq_val(knn_black_loc_rent$pred,validation_loc_rent_nna$percblack)

# loc/rent percentage asian model
knn_asian_loc_rent <- knn.reg(train=training_loc_rent_only,test=validation_loc_rent_only,
                              y=training_loc_rent_nna$percasian,k=4)
summary(knn_asian_loc_rent$pred)
rsq_val(knn_asian_loc_rent$pred,validation_loc_rent_nna$percasian)

knn_white_loc_rent_preds_by_zip <- data.frame("zipCode"=validation_loc_rent_nna$zipCode,
                                              "loc_rent_pred"=knn_white_loc_rent$pred)

knn_white_loc_preds_by_zip <- data.frame("zipCode"=validation_data_withlat$zipCode,
                                     "loc_pred"=knn_white_loc$pred)

combined_preds <- merge(knn_white_loc_rent_preds_by_zip, knn_white_loc_preds_by_zip,
                        all.x=FALSE, all.y=TRUE)
combined_preds$loc_rent_pred[is.na(combined_preds$loc_rent_pred)] <- 
  combined_preds$loc_pred[is.na(combined_preds$loc_rent_pred)]

View(combined_preds)

combined_fit <- lm(validation_data_withlat$percwhite ~ combined_preds$loc_rent_pred + combined_preds$loc_pred)

#slightly improved!

